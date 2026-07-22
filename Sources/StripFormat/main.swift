import Cocoa

let app = NSApplication.shared
let provider = ServiceProvider()
app.servicesProvider = provider
app.setActivationPolicy(.accessory)  // no Dock icon, equivalent to LSUIElement
app.run()
