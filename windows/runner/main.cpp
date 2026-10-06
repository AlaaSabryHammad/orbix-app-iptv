#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter_windows.h>
#include <windows.h>

#include <algorithm>

#include "flutter_window.h"
#include "utils.h"

namespace {

constexpr const wchar_t kTitle[] = L"Orbix";

// One Orbix at a time: a second launch brings the running window forward
// (both would otherwise open the same database).
bool FocusRunningInstance() {
  ::CreateMutexW(nullptr, TRUE, L"Local\\app.orbix.player");
  if (::GetLastError() != ERROR_ALREADY_EXISTS) {
    return false;
  }
  // Window class registered by win32_window.cpp.
  if (HWND existing = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", kTitle)) {
    if (::IsIconic(existing)) {
      ::ShowWindow(existing, SW_RESTORE);
    }
    ::SetForegroundWindow(existing);
  }
  return true;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  if (FocusRunningInstance()) {
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");
  // Skia, not Impeller (Flutter 3.47): Impeller on Windows drew a hard white
  // ring where coloured soft shadows and gradients fade out (button glows,
  // OxAmbient) on both GPUs of the dev machine, and used ~3x the memory.
  project.set_impeller_switch(flutter::ImpellerSwitch::Disabled);

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  // Tablet-sized (1280×800, the tablet screens of the design), centred in the
  // primary monitor's work area and never larger than 90 % of it.
  RECT work{};
  ::SystemParametersInfoW(SPI_GETWORKAREA, 0, &work, 0);
  const double scale =
      FlutterDesktopGetDpiForMonitor(
          ::MonitorFromPoint({work.left, work.top}, MONITOR_DEFAULTTOPRIMARY)) /
      96.0;
  const double work_w = (work.right - work.left) / scale;
  const double work_h = (work.bottom - work.top) / scale;
  const unsigned int width =
      static_cast<unsigned int>(std::min(1280.0, work_w * 0.9));
  const unsigned int height =
      static_cast<unsigned int>(std::min(800.0, work_h * 0.9));

  FlutterWindow window(project);
  Win32Window::Point origin(
      static_cast<unsigned int>(work.left / scale + (work_w - width) / 2),
      static_cast<unsigned int>(work.top / scale + (work_h - height) / 2));
  Win32Window::Size size(width, height);
  if (!window.Create(kTitle, origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
