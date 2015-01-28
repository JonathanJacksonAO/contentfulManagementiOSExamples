//
//  List.h
//  Contentful Management
//
//  Created by Jonathan Jackson on 12/12/2014.
//  Copyright (c) 2014 Jonathan Jackson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface List : NSObject <NSObject>

@property (nonatomic, readwrite) NSInteger Id;
@property (nonatomic, retain) NSString *UniqueId;
@property (nonatomic, retain) NSString *CountryId;
@property (nonatomic, retain) NSString *CountryName;
@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSString *LocationName;
@property (nonatomic, retain) NSString *Address1;
@property (nonatomic, retain) NSString *Address2;
@property (nonatomic, retain) NSString *Address3;
@property (nonatomic, retain) NSString *Address4;
@property (nonatomic, retain) NSString *Address5;
@property (nonatomic, retain) NSString *Address6;
@property (nonatomic, retain) NSString *TelephoneNumber;
@property (nonatomic, retain) NSString *FaxNumber;
@property (nonatomic, retain) NSString *ContactEmailAddress;
@property (nonatomic, retain) NSString *Latitude;
@property (nonatomic, retain) NSString *Longitude;
@property (nonatomic, retain) NSString *Photo;
@property (nonatomic, retain) NSString *CountryPageUniqueId;
@property (nonatomic, retain) NSString *TermStoreId;
@property (nonatomic, retain) NSString *OfficeId;
@property (nonatomic, retain) NSString *Practices;
@property (nonatomic, retain) NSString *FirstName;
@property (nonatomic, retain) NSString *Surname;
@property (nonatomic, retain) NSString *EmailAddress;
@property (nonatomic, retain) NSString *JobRole;
@property (nonatomic, retain) NSString *DefaultBio;
@property (nonatomic, retain) NSString *LanguagesSpoken;
@property (nonatomic, retain) NSString *Experience;
@property (nonatomic, retain) NSString *DateJoined;
@property (nonatomic, retain) NSString *MetaDescription;
@property (nonatomic, retain) NSString *Publications;
@property (nonatomic, retain) NSString *LastUpdated;

@end
