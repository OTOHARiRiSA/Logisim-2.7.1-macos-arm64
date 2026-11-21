package com.cburch.logisim.gui.start;

import java.awt.Desktop;
import java.awt.EventQueue;
import java.util.Arrays;

import com.cburch.logisim.Main;
import com.cburch.logisim.proj.ProjectActions;
import com.cburch.logisim.proj.Projects;

public final class MacLauncher {
    private MacLauncher() {}

    public static void main(String[] args) throws Exception {
        if (Arrays.asList(args).contains("-tty")) {
            Main.main(args);
            return;
        }

        EventQueue.invokeAndWait(() -> {
            registerDesktopHandlers();
            Main.main(args);
        });
    }

    private static void registerDesktopHandlers() {
        if (!Desktop.isDesktopSupported()) {
            return;
        }

        Desktop desktop = Desktop.getDesktop();
        if (desktop.isSupported(Desktop.Action.APP_OPEN_FILE)) {
            desktop.setOpenFileHandler(event -> event.getFiles().forEach(Startup::doOpen));
        }
        if (desktop.isSupported(Desktop.Action.APP_PRINT_FILE)) {
            desktop.setPrintFileHandler(event -> event.getFiles().forEach(Startup::doPrint));
        }
        if (desktop.isSupported(Desktop.Action.APP_QUIT_HANDLER)) {
            desktop.setQuitHandler((event, response) -> {
                if (Projects.getTopFrame() == null) {
                    response.performQuit();
                } else {
                    response.cancelQuit();
                    ProjectActions.doQuit();
                }
            });
        }
    }
}
