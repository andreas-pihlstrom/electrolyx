{
  "targets": [
    {
      "target_name": "electrolyx",
      "sources": [
        "src/native/electrolyx.mm"
      ],
      "include_dirs": [
        "<!@(node -p \"require('node-addon-api').include\")"
      ],
      "dependencies": [
        "<!(node -p \"require('node-addon-api').gyp\")"
      ],
      "defines": [
        "NAPI_DISABLE_CPP_EXCEPTIONS"
      ],
      "conditions": [
        [
          "OS=='mac'",
          {
            "xcode_settings": {
              "MACOSX_DEPLOYMENT_TARGET": "10.14",
              "GCC_ENABLE_CPP_EXCEPTIONS": "NO",
              "CLANG_CXX_LIBRARY": "libc++",
              "OTHER_CFLAGS": [
                "-fobjc-arc"
              ],
              "OTHER_CPLUSPLUSFLAGS": [
                "-std=c++17",
                "-stdlib=libc++"
              ],
              "OTHER_LDFLAGS": [
                "-framework AppKit",
                "-framework QuartzCore",
                "-framework CoreGraphics"
              ]
            }
          }
        ]
      ]
    }
  ]
}
