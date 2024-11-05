//#pragma once
//#include <functional>
//#include <map>
//#include <memory>
//#include <string>
//#include <Windows.h>
//#include <unordered_map>
//
//#ifdef DISABLE_IMGUI
//#define IMGUI_FUNCTION( function, code ) function {}
//#else
//#define IMGUI_FUNCTION( function, code ) function { code }
//#endif
//
//class ImguiDisplay
//{
//
//public:
//
//    struct MenuItem
//    {
//        std::function<void()> imgui_function;
//        std::string name;
//        bool visible;
//    };
//
//    struct Menu
//    {
//        std::vector<MenuItem> items;
//    };
//
//    ImguiDisplay();
//
//    static void DisplayHook();
//    static void InputHook( UINT msg, WPARAM w_param, LPARAM l_param );
//
//    static void Create()
//    {
//#ifndef DISABLE_IMGUI
//        display = std::make_unique<ImguiDisplay>();
//#endif
//    }
//    static void Destroy()
//    {
//#ifndef DISABLE_IMGUI
//        display = nullptr;
//#endif
//    }
//
//    static std::unique_ptr<ImguiDisplay>& Get() { return display; }
//
//    static void AddImguiItem( const std::string& menu, const std::string& name, std::function<void()>&& imgui_function );
//
//private:
//    static std::unique_ptr<ImguiDisplay> display;
//
//    void Display();
//    void Input( UINT msg, WPARAM w_param, LPARAM l_param );
//
//
//    std::map<std::string, Menu> menus;
//};
