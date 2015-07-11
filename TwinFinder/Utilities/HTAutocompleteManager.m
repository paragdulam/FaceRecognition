//
//  HTAutocompleteManager.m
//  HotelTonight
//
//  Created by Jonathan Sibley on 12/6/12.
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//

#import "HTAutocompleteManager.h"

static HTAutocompleteManager *sharedManager;

@implementation HTAutocompleteManager

+ (HTAutocompleteManager *)sharedManager
{
	static dispatch_once_t done;
	dispatch_once(&done, ^{ sharedManager = [[HTAutocompleteManager alloc] init]; });
	return sharedManager;
}

#pragma mark - HTAutocompleteTextFieldDelegate

- (NSString *)textField:(HTAutocompleteTextField *)textField
    completionForPrefix:(NSString *)prefix
             ignoreCase:(BOOL)ignoreCase
{
    if (textField.autocompleteType == HTAutocompleteTypeEmail)
    {
        static dispatch_once_t onceToken;
        static NSArray *autocompleteArray;
        dispatch_once(&onceToken, ^
                      {
                          autocompleteArray = @[  @"gmail.com",
                                                  @"yahoo.com",
                                                  @"hotmail.com",
                                                  @"aol.com",
                                                  @"comcast.net",
                                                  @"me.com",
                                                  @"msn.com",
                                                  @"live.com",
                                                  @"sbcglobal.net",
                                                  @"ymail.com",
                                                  @"att.net",
                                                  @"mac.com",
                                                  @"cox.net",
                                                  @"verizon.net",
                                                  @"hotmail.co.uk",
                                                  @"bellsouth.net",
                                                  @"rocketmail.com",
                                                  @"aim.com",
                                                  @"yahoo.co.uk",
                                                  @"earthlink.net",
                                                  @"charter.net",
                                                  @"optonline.net",
                                                  @"shaw.ca",
                                                  @"yahoo.ca",
                                                  @"googlemail.com",
                                                  @"mail.com",
                                                  @"qq.com",
                                                  @"btinternet.com",
                                                  @"mail.ru",
                                                  @"live.co.uk",
                                                  @"naver.com",
                                                  @"rogers.com",
                                                  @"juno.com",
                                                  @"yahoo.com.tw",
                                                  @"live.ca",
                                                  @"walla.com",
                                                  @"163.com",
                                                  @"roadrunner.com",
                                                  @"telus.net",
                                                  @"embarqmail.com",
                                                  @"hotmail.fr",
                                                  @"pacbell.net",
                                                  @"sky.com",
                                                  @"sympatico.ca",
                                                  @"cfl.rr.com",
                                                  @"tampabay.rr.com",
                                                  @"q.com",
                                                  @"yahoo.co.in",
                                                  @"yahoo.fr",
                                                  @"hotmail.ca",
                                                  @"windstream.net",
                                                  @"hotmail.it",
                                                  @"web.de",
                                                  @"asu.edu",
                                                  @"gmx.de",
                                                  @"gmx.com",
                                                  @"insightbb.com",
                                                  @"netscape.net",
                                                  @"icloud.com",
                                                  @"frontier.com",
                                                  @"126.com",
                                                  @"hanmail.net",
                                                  @"suddenlink.net",
                                                  @"netzero.net",
                                                  @"mindspring.com",
                                                  @"ail.com",
                                                  @"windowslive.com",
                                                  @"netzero.com",
                                                  @"yahoo.com.hk",
                                                  @"yandex.ru",
                                                  @"mchsi.com",
                                                  @"cableone.net",
                                                  @"yahoo.com.cn",
                                                  @"yahoo.es",
                                                  @"yahoo.com.br",
                                                  @"cornell.edu",
                                                  @"ucla.edu",
                                                  @"us.army.mil",
                                                  @"excite.com",
                                                  @"ntlworld.com",
                                                  @"usc.edu",
                                                  @"nate.com",
                                                  @"outlook.com",
                                                  @"nc.rr.com",
                                                  @"prodigy.net",
                                                  @"wi.rr.com",
                                                  @"videotron.ca",
                                                  @"yahoo.it",
                                                  @"yahoo.com.au",
                                                  @"umich.edu",
                                                  @"ameritech.net",
                                                  @"libero.it",
                                                  @"yahoo.de",
                                                  @"rochester.rr.com",
                                                  @"cs.com",
                                                  @"frontiernet.net",
                                                  @"swbell.net",
                                                  @"msu.edu",
                                                  @"ptd.net",
                                                  @"proxymail.facebook.com",
                                                  @"hotmail.es",
                                                  @"austin.rr.com",
                                                  @"nyu.edu",
                                                  @"sina.com",
                                                  @"centurytel.net",
                                                  @"usa.net",
                                                  @"nycap.rr.com",
                                                  @"uci.edu",
                                                  @"hotmail.de",
                                                  @"yahoo.com.sg",
                                                  @"email.arizona.edu",
                                                  @"yahoo.com.mx",
                                                  @"ufl.edu",
                                                  @"bigpond.com",
                                                  @"unlv.nevada.edu",
                                                  @"yahoo.cn",
                                                  @"ca.rr.com",
                                                  @"google.com",
                                                  @"yahoo.co.id",
                                                  @"inbox.com",
                                                  @"fuse.net",
                                                  @"hawaii.rr.com",
                                                  @"talktalk.net",
                                                  @"gmx.net",
                                                  @"walla.co.il",
                                                  @"ucdavis.edu",
                                                  @"carolina.rr.com",
                                                  @"comcast.com",
                                                  @"live.fr",
                                                  @"blueyonder.co.uk",
                                                  @"live.cn",
                                                  @"cogeco.ca",
                                                  @"abv.bg",
                                                  @"tds.net",
                                                  @"centurylink.net",
                                                  @"yahoo.com.vn",
                                                  @"uol.com.br",
                                                  @"osu.edu",
                                                  @"san.rr.com",
                                                  @"rcn.com",
                                                  @"umn.edu",
                                                  @"live.nl",
                                                  @"live.com.au",
                                                  @"tx.rr.com",
                                                  @"eircom.net",
                                                  @"sasktel.net",
                                                  @"post.harvard.edu",
                                                  @"snet.net",
                                                  @"wowway.com",
                                                  @"live.it",
                                                  @"hoteltonight.com",
                                                  @"att.com",
                                                  @"vt.edu",
                                                  @"rambler.ru",
                                                  @"temple.edu",
                                                  @"cinci.rr.com"];
                      });
        
        // Check that text field contains an @
        NSRange atSignRange = [prefix rangeOfString:@"@"];
        if (atSignRange.location == NSNotFound)
        {
            return @"";
        }
        
        // Stop autocomplete if user types dot after domain
        NSString *domainAndTLD = [prefix substringFromIndex:atSignRange.location];
        NSRange rangeOfDot = [domainAndTLD rangeOfString:@"."];
        if (rangeOfDot.location != NSNotFound)
        {
            return @"";
        }
        
        // Check that there aren't two @-signs
        NSArray *textComponents = [prefix componentsSeparatedByString:@"@"];
        if ([textComponents count] > 2)
        {
            return @"";
        }
        
        if ([textComponents count] > 1)
        {
            // If no domain is entered, use the first domain in the list
            if ([(NSString *)textComponents[1] length] == 0)
            {
                return [autocompleteArray objectAtIndex:0];
            }
            
            NSString *textAfterAtSign = textComponents[1];
            
            NSString *stringToLookFor;
            if (ignoreCase)
            {
                stringToLookFor = [textAfterAtSign lowercaseString];
            }
            else
            {
                stringToLookFor = textAfterAtSign;
            }
            
            for (NSString *stringFromReference in autocompleteArray)
            {
                NSString *stringToCompare;
                if (ignoreCase)
                {
                    stringToCompare = [stringFromReference lowercaseString];
                }
                else
                {
                    stringToCompare = stringFromReference;
                }
                
                if ([stringToCompare hasPrefix:stringToLookFor])
                {
                    return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
                }
                
            }
        }
    }
    else if (textField.autocompleteType == HTAutocompleteTypeColor)
    {
        static dispatch_once_t colorOnceToken;
        static NSArray *colorAutocompleteArray;
        dispatch_once(&colorOnceToken, ^
        {
            colorAutocompleteArray = @[ @"Alfred",
                                        @"Beth",
                                        @"Carlos",
                                        @"Daniel",
                                        @"Ethan",
                                        @"Fred",
                                        @"George",
                                        @"Helen",
                                        @"Inis",
                                        @"Jennifer",
                                        @"Kylie",
                                        @"Liam",
                                        @"Melissa",
                                        @"Noah",
                                        @"Omar",
                                        @"Penelope",
                                        @"Quan",
                                        @"Rachel",
                                        @"Seth",
                                        @"Timothy",
                                        @"Ulga",
                                        @"Vanessa",
                                        @"William",
                                        @"Xao",
                                        @"Yilton",
                                        @"Zander"];
        });

        NSString *stringToLookFor;
		NSArray *componentsString = [prefix componentsSeparatedByString:@","];
        NSString *prefixLastComponent = [componentsString.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (ignoreCase)
        {
            stringToLookFor = [prefixLastComponent lowercaseString];
        }
        else
        {
            stringToLookFor = prefixLastComponent;
        }
        
        for (NSString *stringFromReference in colorAutocompleteArray)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = [stringFromReference lowercaseString];
            }
            else
            {
                stringToCompare = stringFromReference;
            }
            
            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }
            
        }
    }
    else if (textField.autocompleteType == HTAutocompleteTypeCountry)
    {
        static dispatch_once_t colorOnceToken;
        static NSArray *colorAutocompleteArray;
        dispatch_once(&colorOnceToken, ^
                      {
                          colorAutocompleteArray = @[ @"Abkhazia",
                                                      @"Afghanistan",
                                                      @"Aland",
                                                      @"Albania",
                                                      @"Algeria",
                                                      @"American-Samoa",
                                                      @"Andorra",
                                                      @"Angola",
                                                      @"Anguilla",
                                                      @"Antarctica",
                                                      @"Antigua-and-Barbuda",
                                                      @"Argentina",
                                                      @"Armenia",
                                                      @"Aruba",
                                                      @"Australia",
                                                      @"Austria",
                                                      @"Azerbaijan",
                                                      @"Bahamas",
                                                      @"Bahrain",
                                                      @"Bangladesh",
                                                      @"Barbados",
                                                      @"Basque-Country",
                                                      @"Belarus",
                                                      @"Belgium",
                                                      @"Belize",
                                                      @"Benin",
                                                      @"Bermuda",
                                                      @"Bhutan",
                                                      @"Bolivia",
                                                      @"Bosnia-and-Herzegovina",
                                                      @"Botswana",
                                                      @"Brazil",
                                                      @"British-Antarctic-Territory",
                                                      @"British-Virgin-Islands",
                                                      @"Brunei",
                                                      @"Bulgaria",
                                                      @"Burkina-Faso",
                                                      @"Burundi",
                                                      @"Cambodia",
                                                      @"Cameroon",
                                                      @"Canada",
                                                      @"Canary-Islands",
                                                      @"Cape-Verde",
                                                      @"Cayman-Islands",
                                                      @"Central-African-Republic",
                                                      @"Chad",
                                                      @"Chile",
                                                      @"China",
                                                      @"Christmas-Island",
                                                      @"Cocos-Keeling-Islands",
                                                      @"Colombia",
                                                      @"Commonwealth",
                                                      @"Comoros",
                                                      @"Cook-Islands",
                                                      @"Costa-Rica",
                                                      @"Cote-dIvoire",
                                                      @"Croatia",
                                                      @"Cuba",
                                                      @"Curacao",
                                                      @"Cyprus",
                                                      @"Czech-Republic",
                                                      @"Democratic-Republic-of-the-Congo",
                                                      @"Denmark",
                                                      @"Djibouti",
                                                      @"Dominica",
                                                      @"Dominican-Republic",
                                                      @"East-Timor",
                                                      @"Ecuador",
                                                      @"Egypt",
                                                      @"El-Salvador",
                                                      @"England",
                                                      @"Equatorial-Guinea",
                                                      @"Eritrea",
                                                      @"Estonia",
                                                      @"Ethiopia",
                                                      @"European-Union",
                                                      @"Falkland-Islands",
                                                      @"Faroes",
                                                      @"Fiji",
                                                      @"Finland",
                                                      @"France",
                                                      @"French-Polynesia",
                                                      @"Gabon",
                                                      @"Gambia",
                                                      @"Georgia",
                                                      @"Germany",
                                                      @"Ghana",
                                                      @"Gibraltar",
                                                      @"Greece",
                                                      @"Greenland",
                                                      @"Grenada",
                                                      @"Guam",
                                                      @"Guatemala",
                                                      @"Guernsey",
                                                      @"Guinea-Bissau",
                                                      @"Guinea",
                                                      @"Guyana",
                                                      @"Haiti",
                                                      @"Honduras",
                                                      @"Hong-Kong",
                                                      @"Hungary",
                                                      @"Iceland",
                                                      @"India",
                                                      @"Indonesia",
                                                      @"Iran",
                                                      @"Iraq",
                                                      @"Ireland",
                                                      @"Isle-of-Man",
                                                      @"Israel",
                                                      @"Italy",
                                                      @"Jamaica",
                                                      @"Japan",
                                                      @"Jersey",
                                                      @"Jordan",
                                                      @"Kazakhstan",
                                                      @"Kenya",
                                                      @"Kiribati",
                                                      @"Kosovo",
                                                      @"Kuwait",
                                                      @"Kyrgyzstan",
                                                      @"Laos",
                                                      @"Latvia",
                                                      @"Lebanon",
                                                      @"Lesotho",
                                                      @"Liberia",
                                                      @"Libya",
                                                      @"Liechtenstein",
                                                      @"Lithuania",
                                                      @"Luxembourg",
                                                      @"Macau",
                                                      @"Macedonia",
                                                      @"Madagascar",
                                                      @"Malawi",
                                                      @"Malaysia",
                                                      @"Maldives",
                                                      @"Mali",
                                                      @"Malta",
                                                      @"Mars",
                                                      @"Marshall-Islands",
                                                      @"Martinique",
                                                      @"Mauritania",
                                                      @"Mauritius",
                                                      @"Mayotte",
                                                      @"Mexico",
                                                      @"Micronesia",
                                                      @"Moldova",
                                                      @"Monaco",
                                                      @"Mongolia",
                                                      @"Montenegro",
                                                      @"Montserrat",
                                                      @"Morocco",
                                                      @"Mozambique",
                                                      @"Myanmar",
                                                      @"Nagorno-Karabakh",
                                                      @"Namibia",
                                                      @"NATO",
                                                      @"Nauru",
                                                      @"Nepal",
                                                      @"Netherlands-Antilles",
                                                      @"Netherlands",
                                                      @"New-Caledonia",
                                                      @"New-Zealand",
                                                      @"Nicaragua",
                                                      @"Niger",
                                                      @"Nigeria",
                                                      @"Niue",
                                                      @"Norfolk-Island",
                                                      @"North-Korea",
                                                      @"Northern-Cyprus",
                                                      @"Northern-Mariana-Islands",
                                                      @"Norway",
                                                      @"Oman",
                                                      @"Pakistan",
                                                      @"Palau",
                                                      @"Palestine",
                                                      @"Panama",
                                                      @"Papua-New-Guinea",
                                                      @"Paraguay",
                                                      @"Peru",
                                                      @"Philippines",
                                                      @"Pitcairn-Islands",
                                                      @"Poland",
                                                      @"Portugal",
                                                      @"Puerto-Rico",
                                                      @"Qatar",
                                                      @"Republic-of-the-Congo",
                                                      @"Romania",
                                                      @"Russia",
                                                      @"Rwanda",
                                                      @"Saint-Barthelemy",
                                                      @"Saint-Helena",
                                                      @"Saint-Kitts-and-Nevis",
                                                      @"Saint-Lucia",
                                                      @"Saint-Martin",
                                                      @"Saint-Vincent-and-the-Grenadines",
                                                      @"Samoa",
                                                      @"San-Marino",
                                                      @"Sao-Tome-and-Principe",
                                                      @"Saudi-Arabia",
                                                      @"Scotland",
                                                      @"Senegal",
                                                      @"Serbia",
                                                      @"Seychelles",
                                                      @"Sierra-Leone",
                                                      @"Singapore",
                                                      @"Slovakia",
                                                      @"Slovenia",
                                                      @"Solomon-Islands",
                                                      @"Somalia",
                                                      @"Somaliland",
                                                      @"South-Africa",
                                                      @"South-Georgia-and-the-South-Sandwich-Islands",
                                                      @"South-Korea",
                                                      @"South-Ossetia",
                                                      @"South-Sudan",
                                                      @"Spain",
                                                      @"Sri-Lanka",
                                                      @"Sudan",
                                                      @"Suriname",
                                                      @"Swaziland",
                                                      @"Sweden",
                                                      @"Switzerland",
                                                      @"Syria",
                                                      @"Taiwan",
                                                      @"Tajikistan",
                                                      @"Tanzania",
                                                      @"Thailand",
                                                      @"Togo",
                                                      @"Tokelau",
                                                      @"Tonga",
                                                      @"Trinidad-and-Tobago",
                                                      @"Tunisia",
                                                      @"Turkey",
                                                      @"Turkmenistan",
                                                      @"Turks-and-Caicos-Islands",
                                                      @"Tuvalu",
                                                      @"Uganda",
                                                      @"Ukraine",
                                                      @"United-Arab-Emirates",
                                                      @"United-Kingdom",
                                                      @"United-States",
                                                      @"Uruguay",
                                                      @"US-Virgin-Islands",
                                                      @"Uzbekistan",
                                                      @"Vanuatu",
                                                      @"Vatican-City",
                                                      @"Venezuela",
                                                      @"Vietnam",
                                                      @"Wales",
                                                      @"Wallis-And-Futuna",
                                                      @"Western-Sahara",
                                                      @"Yemen",
                                                      @"Zambia",
                                                      @"Zimbabwe"];
                      });
        
        NSString *stringToLookFor;
        NSArray *componentsString = [prefix componentsSeparatedByString:@","];
        NSString *prefixLastComponent = [componentsString.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (ignoreCase)
        {
            stringToLookFor = [prefixLastComponent lowercaseString];
        }
        else
        {
            stringToLookFor = prefixLastComponent;
        }
        
        for (NSString *stringFromReference in colorAutocompleteArray)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = [stringFromReference lowercaseString];
            }
            else
            {
                stringToCompare = stringFromReference;
            }
            
            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }
            
        }
    }
    
    return @"";
}

@end
