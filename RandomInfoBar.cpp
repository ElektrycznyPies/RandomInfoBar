// Random Info Bar - native Windows x64 version of the supplied PowerShell script.
// Build: x86_64-w64-mingw32-clang++ RandomInfoBar.cpp -o RandomInfoBar.exe
//        -std=c++17 -Os -s -mwindows -static -lgdi32 -luser32 -liphlpapi
// Exit: click the bar, then press Alt+F4.
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <iphlpapi.h>
#include <cstdlib>
#include <cwchar>

constexpr int Width = 600, Height = 20;
constexpr UINT_PTR MoveTimer = 1, ClockTimer = 2, NetworkTimer = 3;
constexpr UINT MoveInterval = 60000, ClockInterval = 100, NetworkInterval = 1500;
HFONT font = nullptr;
wchar_t line[512] = {};
wchar_t network[96] = L"net check";
const wchar_t* networkSymbol = L"";

void UpdateNetwork() {
    MIB_IF_TABLE2* table = nullptr;
    if (GetIfTable2(&table) != NO_ERROR) {
        std::wcscpy(network, L"NET ERROR");
        networkSymbol = L"?";
        return;
    }
    std::wcscpy(network, L"NO NET");
    networkSymbol = L"\u21D3";
    for (ULONG i = 0; i < table->NumEntries; ++i) {
        const MIB_IF_ROW2& adapter = table->Table[i];
        if (!adapter.InterfaceAndOperStatusFlags.HardwareInterface ||
            adapter.OperStatus != IfOperStatusUp) continue;
        // Like the PS foreach, the last active physical adapter wins.
        // This reports link status, not verified Internet access.
        switch (adapter.Type) {
        case 6:   std::wcscpy(network, L"ETH"); break;
        case 71:  std::wcscpy(network, L"WI-FI"); break;
        case 243:
        case 244: std::wcscpy(network, L"GSM"); break;
        default:  std::swprintf(network, 96, L"OTHER: (%lu)", adapter.Type);
        }
        networkSymbol = L"\u21D1";
    }
    FreeMibTable(table);
}

void UpdateText(HWND window, bool initial = false) {
    SYSTEMTIME now;
    GetLocalTime(&now);
    wchar_t time[32] = {}, date[256] = {}, next[512] = {};
    GetTimeFormatEx(LOCALE_NAME_USER_DEFAULT, 0, &now,
                    L"HH':'mm':'ss", time, 32);
    GetDateFormatEx(LOCALE_NAME_USER_DEFAULT, 0, &now,
                    L"dddd, d MMMM yyyy", date, 256, nullptr);
    if (initial) {
        std::swprintf(next, 512, L"[ %ls ]  |  %ls", time, date);
    } else {
        std::swprintf(next, 512, L"[ %ls ]     %ls    %ls %ls %ls",
                      time, date, networkSymbol, network, networkSymbol);
    }
    if (std::wcscmp(line, next) != 0) {
        std::wcscpy(line, next);
        InvalidateRect(window, nullptr, FALSE);
    }
}

void MoveBar(HWND window) {
    const int maxX = GetSystemMetrics(SM_CXSCREEN) - Width;
    const int x = maxX > 0 ? std::rand() % maxX : 0;
    const int y = GetSystemMetrics(SM_CYSCREEN) - Height;
    SetWindowPos(window, HWND_TOPMOST, x, y > 0 ? y : 0, Width, Height,
                 SWP_NOACTIVATE);
}

LRESULT CALLBACK WindowProc(HWND window, UINT message,
                            WPARAM wParam, LPARAM lParam) {
    switch (message) {
    case WM_TIMER:
        switch (wParam) {
        case MoveTimer:    MoveBar(window); break;
        case ClockTimer:   UpdateText(window); break;
        case NetworkTimer: UpdateNetwork(); break;
        }
        return 0;
    case WM_DISPLAYCHANGE:
        MoveBar(window);
        return 0;
    case WM_ERASEBKGND:
        return 1; // Paint background and text together.
    case WM_PAINT: {
        PAINTSTRUCT paint;
        HDC dc = BeginPaint(window, &paint);
        RECT rect;
        GetClientRect(window, &rect);
        FillRect(dc, &rect, static_cast<HBRUSH>(GetStockObject(BLACK_BRUSH)));
        HGDIOBJ oldFont = SelectObject(dc, font);
        SetTextColor(dc, RGB(255, 255, 255));
        SetBkMode(dc, TRANSPARENT);
        DrawTextW(dc, line, -1, &rect,
                  DT_CENTER | DT_VCENTER | DT_SINGLELINE | DT_NOPREFIX);
        SelectObject(dc, oldFont);
        EndPaint(window, &paint);
        return 0;
    }
    case WM_DESTROY:
        KillTimer(window, MoveTimer);
        KillTimer(window, ClockTimer);
        KillTimer(window, NetworkTimer);
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProcW(window, message, wParam, lParam);
}

int WINAPI WinMain(HINSTANCE instance, HINSTANCE, LPSTR, int) {
    std::srand(GetTickCount());
    WNDCLASSW wc{};
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = instance;
    wc.hCursor = LoadCursorW(nullptr, MAKEINTRESOURCEW(32512));
    wc.lpszClassName = L"RandomInfoBar";
    if (!RegisterClassW(&wc)) return 1;

    // 16 pt at the default 96 DPI. Windows handles legacy DPI scaling.
    font = CreateFontW(-MulDiv(16, 96, 72), 0, 0, 0, FW_NORMAL,
                       FALSE, FALSE, FALSE, DEFAULT_CHARSET,
                       OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                       DEFAULT_QUALITY, DEFAULT_PITCH, L"Helvetica");
    if (!font) return 1;
    HWND window = CreateWindowExW(
        WS_EX_TOPMOST | WS_EX_TOOLWINDOW | WS_EX_LAYERED,
        wc.lpszClassName, L"Random Info Bar", WS_POPUP,
        0, 0, Width, Height, nullptr, nullptr, instance, nullptr);
    if (!window) { DeleteObject(font); return 1; }

    if (!SetLayeredWindowAttributes(window, 0, 204, LWA_ALPHA) ||
        !SetTimer(window, MoveTimer, MoveInterval, nullptr) ||
        !SetTimer(window, ClockTimer, ClockInterval, nullptr) ||
        !SetTimer(window, NetworkTimer, NetworkInterval, nullptr)) {
        DestroyWindow(window);
        DeleteObject(font);
        return 1;
    }
    UpdateText(window, true);
    MoveBar(window);
    ShowWindow(window, SW_SHOWNORMAL);
    MSG message{};
    BOOL result;
    while ((result = GetMessageW(&message, nullptr, 0, 0)) > 0) {
        TranslateMessage(&message);
        DispatchMessageW(&message);
    }
    if (IsWindow(window)) DestroyWindow(window);
    DeleteObject(font);
    return result == -1 ? 1 : 0;
}
