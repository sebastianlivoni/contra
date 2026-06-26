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

struct UnscrollDriver_IVars
{
    OSArray *elements;
    
    struct {
        IOHIDElement *vWheel; // Vertical scroll
        IOHIDElement *hPan;   // Horizontal scroll
    } scroll;
};

#define _elements     ivars->elements
#define _scroll       ivars->scroll

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
