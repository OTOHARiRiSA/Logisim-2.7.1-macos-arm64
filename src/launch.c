#include <jni.h>
#include <limits.h>
#include <mach-o/dyld.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int JLI_Launch(int argc, char **argv, int jargc, const char **jargv,
                      int appclassc, const char **appclassv,
                      const char *fullversion, const char *dotversion,
                      const char *pname, const char *lname, jboolean javaargs,
                      jboolean cpwildcard, jboolean javaw, jint ergo);

static int launch_java(int argc, char **argv) {
    return JLI_Launch(argc, argv, 0, NULL, 0, NULL,
                      JAVA_VERSION, "11", "java", "openjdk",
                      JNI_FALSE, JNI_TRUE, JNI_FALSE, 0);
}

int main(int argc, char **argv) {
    // JLI starts a Java worker by calling main again with the prepared arguments.
    if (!pthread_main_np()) {
        return launch_java(argc, argv);
    }

    char executable[PATH_MAX];
    char resolved[PATH_MAX];
    uint32_t size = sizeof(executable);
    if (_NSGetExecutablePath(executable, &size) != 0 ||
        realpath(executable, resolved) == NULL) {
        fputs("Logisim: could not resolve the application path.\n", stderr);
        return EXIT_FAILURE;
    }

    char *last_slash = strrchr(resolved, '/');
    if (last_slash == NULL) {
        return EXIT_FAILURE;
    }
    *last_slash = '\0';

    char launcher_jar[PATH_MAX];
    int path_length = snprintf(launcher_jar, sizeof(launcher_jar),
                               "%s/../Resources/Java/mac-launcher.jar", resolved);
    if (path_length < 0 || (size_t)path_length >= sizeof(launcher_jar)) {
        fputs("Logisim: the application path is too long.\n", stderr);
        return EXIT_FAILURE;
    }

    char *options[] = {
        argv[0],
        "-Xdock:name=Logisim",
        "-Dapple.laf.useScreenMenuBar=true",
        "-jar",
        launcher_jar,
    };
    const int option_count = sizeof(options) / sizeof(options[0]);
    char **java_argv = calloc((size_t)argc + option_count, sizeof(*java_argv));
    if (java_argv == NULL) {
        perror("Logisim");
        return EXIT_FAILURE;
    }

    memcpy(java_argv, options, sizeof(options));
    int java_argc = option_count;
    for (int i = 1; i < argc; i++) {
        if (i == 1 && strncmp(argv[i], "-psn_", sizeof("-psn_") - 1) == 0) {
            continue;
        }
        java_argv[java_argc++] = argv[i];
    }

    int status = launch_java(java_argc, java_argv);
    free(java_argv);
    return status;
}
