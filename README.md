# vtwsclib for Objective C

## Dependencies

### JSON Framework

    <https://github.com/stig/json-framework>

The NSJSONSerialization class was not introduced until iOS 5, but the iPhone 3G maxed out at iOS version 4.2.1, so you'll need to build this library and link it into your project.

### vtiger CRM Webservice Client Library

    <http://forge.vtiger.com/projects/vtwsclib>

Though based on the PHP vtwsclib, this library does not currently implement all of its methods.  It does however provide a new doPostFile method that allows you to upload files to the Documents module.

## Additional Documentation

    <https://wiki.vtiger.com/index.php/Webservices_tutorials>
    <https://wiki.vtiger.com/index.php/Webservice_reference_manual>
