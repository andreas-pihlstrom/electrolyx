#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import <napi.h>

// Private API declarations for window corner radius
// These are undocumented macOS APIs - use at your own risk
@interface NSWindow (Private)
- (void)_setCornerRadius:(CGFloat)radius;
- (CGFloat)_cornerRadius;
@end

namespace electradii {

// Get NSWindow from Electron BrowserWindow handle
NSWindow* GetNSWindow(Napi::Value windowHandle) {
    if (!windowHandle.IsBuffer()) {
        return nullptr;
    }

    Napi::Buffer<void*> buffer = windowHandle.As<Napi::Buffer<void*>>();
    void** ptr = reinterpret_cast<void**>(buffer.Data());
    if (ptr && *ptr) {
        return (__bridge NSWindow*)(*ptr);
    }
    return nullptr;
}

// Set custom corner radius using private API
Napi::Value SetWindowCornerRadius(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();

    if (info.Length() < 2) {
        Napi::TypeError::New(env, "Expected 2 arguments: windowHandle and radius")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    NSWindow* window = GetNSWindow(info[0]);
    if (!window) {
        Napi::TypeError::New(env, "Invalid window handle")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    double radius = info[1].As<Napi::Number>().DoubleValue();

    @try {
        // Attempt to use private API
        if ([window respondsToSelector:@selector(_setCornerRadius:)]) {
            [window _setCornerRadius:radius];
            return Napi::Boolean::New(env, true);
        } else {
            Napi::Error::New(env, "Corner radius API not available on this macOS version")
                .ThrowAsJavaScriptException();
            return Napi::Boolean::New(env, false);
        }
    }
    @catch (NSException *exception) {
        Napi::Error::New(env, [[exception reason] UTF8String])
            .ThrowAsJavaScriptException();
        return Napi::Boolean::New(env, false);
    }
}

// Get current corner radius
Napi::Value GetWindowCornerRadius(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();

    if (info.Length() < 1) {
        Napi::TypeError::New(env, "Expected 1 argument: windowHandle")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    NSWindow* window = GetNSWindow(info[0]);
    if (!window) {
        Napi::TypeError::New(env, "Invalid window handle")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    @try {
        if ([window respondsToSelector:@selector(_cornerRadius)]) {
            CGFloat radius = [window _cornerRadius];
            return Napi::Number::New(env, radius);
        } else {
            return Napi::Number::New(env, 0);
        }
    }
    @catch (NSException *exception) {
        Napi::Error::New(env, [[exception reason] UTF8String])
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }
}

// Add vibrancy effect view to window (using public API)
Napi::Value AddVibrancyView(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();

    if (info.Length() < 2) {
        Napi::TypeError::New(env, "Expected at least 2 arguments: windowHandle and options")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    NSWindow* window = GetNSWindow(info[0]);
    if (!window) {
        Napi::TypeError::New(env, "Invalid window handle")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    Napi::Object options = info[1].As<Napi::Object>();

    // Parse options
    NSVisualEffectMaterial material = NSVisualEffectMaterialSidebar;
    NSVisualEffectBlendingMode blendingMode = NSVisualEffectBlendingModeBehindWindow;
    NSVisualEffectState state = NSVisualEffectStateFollowsWindowActiveState;
    CGFloat x = 0, y = 0, width = 200, height = 0;
    CGFloat cornerRadius = 0;

    if (options.Has("material")) {
        std::string mat = options.Get("material").As<Napi::String>().Utf8Value();
        if (mat == "titlebar") material = NSVisualEffectMaterialTitlebar;
        else if (mat == "sidebar") material = NSVisualEffectMaterialSidebar;
        else if (mat == "menu") material = NSVisualEffectMaterialMenu;
        else if (mat == "popover") material = NSVisualEffectMaterialPopover;
        else if (mat == "hudWindow") material = NSVisualEffectMaterialHUDWindow;
        else if (mat == "sheet") material = NSVisualEffectMaterialSheet;
        else if (mat == "tooltip") material = NSVisualEffectMaterialToolTip;
        else if (mat == "underWindowBackground") material = NSVisualEffectMaterialUnderWindowBackground;
    }

    if (options.Has("blendingMode")) {
        std::string mode = options.Get("blendingMode").As<Napi::String>().Utf8Value();
        if (mode == "behindWindow") blendingMode = NSVisualEffectBlendingModeBehindWindow;
        else if (mode == "withinWindow") blendingMode = NSVisualEffectBlendingModeWithinWindow;
    }

    if (options.Has("state")) {
        std::string st = options.Get("state").As<Napi::String>().Utf8Value();
        if (st == "active") state = NSVisualEffectStateActive;
        else if (st == "inactive") state = NSVisualEffectStateInactive;
        else if (st == "followsWindowActiveState") state = NSVisualEffectStateFollowsWindowActiveState;
    }

    // Get contentView BEFORE dispatch_async to avoid issues with Electron's window wrapper
    // Electron may wrap the window, so we need to check if we can get the contentView
    NSView* contentView = nullptr;
    if ([window respondsToSelector:@selector(contentView)]) {
        contentView = window.contentView;
    } else {
        // If window doesn't respond to contentView, it might BE the content view
        // In some Electron versions, the handle points directly to the content view
        contentView = (NSView*)window;
    }

    if (!contentView) {
        Napi::Error::New(env, "Failed to get window content view")
            .ThrowAsJavaScriptException();
        return Napi::Boolean::New(env, false);
    }

    if (options.Has("x")) x = options.Get("x").As<Napi::Number>().DoubleValue();
    if (options.Has("y")) y = options.Get("y").As<Napi::Number>().DoubleValue();
    if (options.Has("width")) width = options.Get("width").As<Napi::Number>().DoubleValue();
    if (options.Has("height")) {
        height = options.Get("height").As<Napi::Number>().DoubleValue();
    } else {
        height = contentView.bounds.size.height;
    }
    if (options.Has("cornerRadius")) cornerRadius = options.Get("cornerRadius").As<Napi::Number>().DoubleValue();

    // Parse autoresizing mask options BEFORE dispatch_async
    NSAutoresizingMaskOptions maskOptions = 0;
    if (options.Has("autoresizingMask")) {
        Napi::Object mask = options.Get("autoresizingMask").As<Napi::Object>();
        if (mask.Has("width") && mask.Get("width").As<Napi::Boolean>().Value()) {
            maskOptions |= NSViewWidthSizable;
        }
        if (mask.Has("height") && mask.Get("height").As<Napi::Boolean>().Value()) {
            maskOptions |= NSViewHeightSizable;
        }
        if (mask.Has("minX") && mask.Get("minX").As<Napi::Boolean>().Value()) {
            maskOptions |= NSViewMinXMargin;
        }
        if (mask.Has("maxX") && mask.Get("maxX").As<Napi::Boolean>().Value()) {
            maskOptions |= NSViewMaxXMargin;
        }
        if (mask.Has("minY") && mask.Get("minY").As<Napi::Boolean>().Value()) {
            maskOptions |= NSViewMinYMargin;
        }
        if (mask.Has("maxY") && mask.Get("maxY").As<Napi::Boolean>().Value()) {
            maskOptions |= NSViewMaxYMargin;
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSVisualEffectView* effectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(x, y, width, height)];
        effectView.material = material;
        effectView.blendingMode = blendingMode;
        effectView.state = state;
        effectView.wantsLayer = YES;

        if (cornerRadius > 0) {
            effectView.layer.cornerRadius = cornerRadius;
            effectView.layer.masksToBounds = YES;
        }

        if (maskOptions != 0) {
            effectView.autoresizingMask = maskOptions;
        }

        [contentView addSubview:effectView positioned:NSWindowBelow relativeTo:nil];
    });

    return Napi::Boolean::New(env, true);
}

// Set window background color
Napi::Value SetWindowBackgroundColor(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();

    if (info.Length() < 4) {
        Napi::TypeError::New(env, "Expected 4 arguments: windowHandle, r, g, b")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    NSWindow* window = GetNSWindow(info[0]);
    if (!window) {
        Napi::TypeError::New(env, "Invalid window handle")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    double r = info[1].As<Napi::Number>().DoubleValue();
    double g = info[2].As<Napi::Number>().DoubleValue();
    double b = info[3].As<Napi::Number>().DoubleValue();
    double a = info.Length() > 4 ? info[4].As<Napi::Number>().DoubleValue() : 1.0;

    dispatch_async(dispatch_get_main_queue(), ^{
        window.backgroundColor = [NSColor colorWithRed:r green:g blue:b alpha:a];
    });

    return Napi::Boolean::New(env, true);
}

// Make window background transparent
Napi::Value SetWindowTransparent(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();

    if (info.Length() < 1) {
        Napi::TypeError::New(env, "Expected 1 argument: windowHandle")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    NSWindow* window = GetNSWindow(info[0]);
    if (!window) {
        Napi::TypeError::New(env, "Invalid window handle")
            .ThrowAsJavaScriptException();
        return env.Undefined();
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        window.backgroundColor = [NSColor clearColor];
        window.opaque = NO;
    });

    return Napi::Boolean::New(env, true);
}

// Initialize the addon
Napi::Object Init(Napi::Env env, Napi::Object exports) {
    exports.Set("setWindowCornerRadius", Napi::Function::New(env, SetWindowCornerRadius));
    exports.Set("getWindowCornerRadius", Napi::Function::New(env, GetWindowCornerRadius));
    exports.Set("addVibrancyView", Napi::Function::New(env, AddVibrancyView));
    exports.Set("setWindowBackgroundColor", Napi::Function::New(env, SetWindowBackgroundColor));
    exports.Set("setWindowTransparent", Napi::Function::New(env, SetWindowTransparent));
    return exports;
}

} // namespace electradii

// Wrapper function for module initialization
napi_value Init(napi_env env, napi_value exports) {
    return electradii::Init(Napi::Env(env), Napi::Object(env, exports));
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)
