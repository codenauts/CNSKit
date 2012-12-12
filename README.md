About
=======
CNSKit is a collection of classes and collections that make life as an iOS developer easier.

Categories
---------------
* NSArray+CNSArrayAdditions.h/.m
* NSDictionary+CNSDictionaryAdditions.h/.m
* NSString+CNSStringAdditions.h/.m
* UIImage+CNSPreloading.h/.m
* UIImageView+CNSURLHandling.h/.m
* UILabels+CNSLabelResize.h/.m

Controllers
---------------
* CNSBaseViewController.h/.m

Data
---------------
* CNSKeychainUtils.h/.m
* CNSPasswordStore.h/.m
* CNSTableViewDataSource.h/.m
* CNSUser.h/.m

Helpers
------------
* CNSClassUtils.h/.m
* CNSConnectionHelper.h/.m
* CNSLogHelper.h/.m

Views
------------
CNSInputCell.h/.m

Usage
======
* Just drop the classes in your xcode-Project and set the no-ARC compiler flag (-fno-objc-arc). As an alternative, CNSKit will be available via [cocoapods](http://cocoapods.org/)
* Make sure the -DDEBUG is set under „Other C Flags“ in your projects settings

Licence
===========
See the [licence file](https://github.com/codenauts/CNSKit/blob/master/LICENSE.md).  