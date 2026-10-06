const { Gio, GLib } = imports.gi;

const bus = Gio.bus_get_sync(Gio.BusType.SESSION, null);
const sender = bus.get_unique_name().replace(/^:/, "").replace(/\./g, "_");
const token = "mangaocr" + Date.now();
const requestPath =
  "/org/freedesktop/portal/desktop/request/" + sender + "/" + token;

const loop = GLib.MainLoop.new(null, false);

bus.signal_subscribe(
  "org.freedesktop.portal.Desktop",
  "org.freedesktop.portal.Request",
  "Response",
  requestPath,
  null,
  Gio.DBusSignalFlags.NONE,
  function (conn, senderName, objectPath, iface, signal, params) {
    const [code, results] = params.recursiveUnpack();
    if (code === 0 && results.uri !== undefined) {
      print(GLib.filename_from_uri(results.uri)[0]);
    }
    loop.quit();
  }
);

try {
  bus.call_sync(
    "org.freedesktop.portal.Desktop",
    "/org/freedesktop/portal/desktop",
    "org.freedesktop.portal.Screenshot",
    "Screenshot",
    new GLib.Variant("(sa{sv})", [
      "",
      {
        interactive: GLib.Variant.new_boolean(true),
        handle_token: GLib.Variant.new_string(token),
      },
    ]),
    null,
    Gio.DBusCallFlags.NONE,
    -1,
    null
  );
} catch (e) {
  printerr("portal screenshot failed: " + e.message);
  imports.system.exit(1);
}

loop.run();
