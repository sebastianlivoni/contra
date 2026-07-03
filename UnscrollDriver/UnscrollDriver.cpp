//
//  UnscrollDriver.cpp
//  UnscrollDriver
//
//  Created by Sebastian on 25/06/2026.
//

#include <os/log.h>
#include <DriverKit/IOUserServer.h>
#include <DriverKit/IOLib.h>
#include <DriverKit/OSCollections.h>
#include <HIDDriverKit/HIDDriverKit.h>

#include "UnscrollDriver.h"

#define USAGE_CMD_MODIFIER     0xE1 // Left GUI / Command key
//#define USAGE_OPEN_BRACKET     0x2F // [
//#define USAGE_CLOSE_BRACKET    0x30 // ]

#define USAGE_OPEN_BRACKET     0x33 // Æ
#define USAGE_CLOSE_BRACKET    0x34 // Ø

struct UnscrollDriver_IVars
{
    OSArray *elements;
    
    struct {
        IOHIDElement *vWheel; // Vertical scroll
        IOHIDElement *hPan;   // Horizontal scroll
    } scroll;
    
    struct {
        IOHIDElement *button4;
        IOHIDElement *button5;
    } sideButtons;
};

#define _elements     ivars->elements
#define _scroll       ivars->scroll
#define _sideButtons       ivars->sideButtons
#define _button4       ivars->sideButtons.button4
#define _button5       ivars->sideButtons.button5

bool UnscrollDriver::init()
{
    if (!super::init()) {
        return false;
    }
    
    ivars = IONewZero(UnscrollDriver_IVars, 1);
    if (!ivars) {
        return false;
    }
    
exit:
    return true;
}

void UnscrollDriver::free()
{
    if (ivars) {
        OSSafeReleaseNULL(_elements);
        OSSafeReleaseNULL(_scroll.vWheel);
        OSSafeReleaseNULL(_scroll.hPan);
        OSSafeReleaseNULL(_sideButtons.button4);
        OSSafeReleaseNULL(_sideButtons.button5);
    }
    
    IOSafeDeleteNULL(ivars, UnscrollDriver_IVars, 1);
    super::free();
}

kern_return_t
IMPL(UnscrollDriver, Start)
{
    kern_return_t ret;
    
    ret = Start(provider, SUPERDISPATCH);
    if (ret != kIOReturnSuccess) {
        Stop(provider, SUPERDISPATCH);
        return ret;
    }
    
    //os_log(OS_LOG_DEFAULT, "Hello World");
    
    _elements = getElements();
    if (!_elements) {
        //os_log(OS_LOG_DEFAULT, "Failed to get elements");
        Stop(provider, SUPERDISPATCH);
        return kIOReturnError;
    }
    
    _elements->retain();
    
    if (!parseElements(_elements)) {
        //os_log(OS_LOG_DEFAULT, "No supported elements found");
        Stop(provider, SUPERDISPATCH);
        return kIOReturnUnsupported;
    }
    
    RegisterService();
    
    return ret;
}

bool UnscrollDriver::parseElements(OSArray *elements)
{
    // 1. Let the base class parse everything it needs (X/Y axes, buttons, etc.)
    // If the base class fails, fail immediately.
    if (!super::parseElements(elements)) {
        return false;
    }
    
    // 2. Now parse our specific scroll elements
    for (unsigned int i = 0; i < elements->getCount(); i++) {
        IOHIDElement *element = OSDynamicCast(IOHIDElement, elements->getObject(i));
        
        if (!element || element->getType() == kIOHIDElementTypeCollection) {
            continue;
        }
        
        uint32_t usagePage = element->getUsagePage();
        uint32_t usage = element->getUsage();
        
        if (usagePage == kHIDPage_GenericDesktop && usage == kHIDUsage_GD_Wheel) {
            _scroll.vWheel = element;
            _scroll.vWheel->retain();
        }
        else if (usagePage == kHIDPage_Consumer && usage == kHIDUsage_Csmr_ACPan) {
            _scroll.hPan = element;
            _scroll.hPan->retain();
        }
        else if (usagePage == kHIDPage_Button) { // Buttons
            if (usage == 0x04) { // Button 4
                _sideButtons.button4 = element;
                _sideButtons.button4->retain();
            }
            else if (usage == 0x05) { // Button 5
                _sideButtons.button5 = element;
                _sideButtons.button5->retain();
            }
        }
    }
    
    // Return true since the base class succeeded and our driver is good to go
    return true;
}

void UnscrollDriver::handleScrollReport(uint64_t timestamp, uint32_t reportID) {
    // 1. Mutate the vertical scroll element value in place
    if (_scroll.vWheel && _scroll.vWheel->getReportID() == reportID) {
        int32_t rawValue = _scroll.vWheel->getValue(0);
        if (rawValue != 0) {
            // Invert the value directly at the source
            _scroll.vWheel->setValue(-rawValue);
        }
    }
    
    // 2. Mutate the horizontal pan element value in place
    if (_scroll.hPan && _scroll.hPan->getReportID() == reportID) {
        int32_t rawValue = _scroll.hPan->getValue(0);
        if (rawValue != 0) {
            // Invert the value directly at the source
            _scroll.hPan->setValue(-rawValue);
        }
    }
    
    // 3. Always pass the modified report to the super class.
    // This gives you the native macOS acceleration curve back!
    super::handleScrollReport(timestamp, reportID);
}

void UnscrollDriver::handleReport(uint64_t timestamp, uint8_t *report, uint32_t reportLength, IOHIDReportType type, uint32_t reportID) {
    if (!_elements) {
        return;
    }
    
    // Tiny offsets to ensure correct chronological sequence in the OS event queue
    uint64_t nsOffset1 = 10000; // 10 microseconds
    uint64_t nsOffset2 = 20000; // 20 microseconds
    
    if (_button4 && _button4->getReportID() == reportID) {
        int32_t isPressed = _button4->getValue(0);
        
        if (isPressed) {
            os_log(OS_LOG_DEFAULT, "Dispatching keyboard event cmd+open_bracket");
            // 1. Command Down
            //dispatchKeyboardEvent(timestamp, kHIDPage_KeyboardOrKeypad, USAGE_CMD_MODIFIER, 1, 0, true);
            // 2. Bracket Down (slightly later)
            dispatchKeyboardEvent(timestamp, kHIDPage_KeyboardOrKeypad, USAGE_OPEN_BRACKET, 1, 0, true);
        } else {
            // 1. Bracket Up
            //dispatchKeyboardEvent(timestamp, kHIDPage_KeyboardOrKeypad, USAGE_OPEN_BRACKET, 0, 0, true);
            // 2. Command Up (slightly later)
            //dispatchKeyboardEvent(timestamp + nsOffset1, kHIDPage_KeyboardOrKeypad, USAGE_CMD_MODIFIER, 0, 0, true);
        }
        
        // Zero out the value in our element tracker
        _sideButtons.button4->setValue(0);
        
        /*
          CRITICAL STEP: If your mouse sends side buttons in a dedicated report,
          or you want to completely consume this report without letting the standard
          mouse driver click pass through, return early and do NOT call super.
        */
        // super::handleReport(timestamp, report, reportLength, type, reportID);
        // return;
    }
    
    if (_button5 && _button5->getReportID() == reportID) {
        int32_t isPressed = _button5->getValue(0);
        
        if (isPressed) {
            os_log(OS_LOG_DEFAULT, "Dispatching keyboard event cmd+close_bracket");
            //dispatchKeyboardEvent(timestamp, kHIDPage_KeyboardOrKeypad, USAGE_CMD_MODIFIER, 1, 0, true);
            dispatchKeyboardEvent(timestamp, kHIDPage_KeyboardOrKeypad, USAGE_CLOSE_BRACKET, 1, 0, true);
        } else {
            //dispatchKeyboardEvent(timestamp, kHIDPage_KeyboardOrKeypad, USAGE_CLOSE_BRACKET, 0, 0, true);
            //dispatchKeyboardEvent(timestamp + nsOffset1, kHIDPage_KeyboardOrKeypad, USAGE_CMD_MODIFIER, 0, 0, true);
        }
        
        _sideButtons.button5->setValue(0);
    }
    
    // Only pass through to the super class if it's a report we didn't want to completely block
    super::handleReport(timestamp, report, reportLength, type, reportID);
}
