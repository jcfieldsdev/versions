/*
 * Copyright (C) 2020 J.C. Fields (jcfields@jcfields.dev).
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/Foundation.h>
#import "GBCli.h"
#import "Controller.h"

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1
#define EXIT_UNKNOWN_OPTION 127

int main(int argc, char **argv) {
    @autoreleasepool {
        GBSettings *settings = [GBSettings
            settingsWithName:@"versions"
            parent:[GBSettings settingsWithName:@"Factory" parent:nil]];
        
        GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
        [parser registerOption:@"help" shortcut:'h' requirement:GBValueNone];
        [parser registerOption:@"view" shortcut:'v' requirement:GBValueRequired];
        [parser registerOption:@"restore" shortcut:'r' requirement:GBValueRequired];
        [parser registerOption:@"replace" shortcut:'p' requirement:GBValueRequired];
        [parser registerOption:@"delete" shortcut:'d' requirement:GBValueRequired];
        [parser registerOption:@"deleteAll" shortcut:'x' requirement:GBValueNone];
        [parser registerSettings:settings];
        
        __block int exitCode = EXIT_SUCCESS;
        
        [parser parseOptionsWithArguments:argv count:argc block:^(GBParseFlags flags, NSString *option, id value, BOOL *stop) {
            switch (flags) {
                case GBParseFlagUnknownOption:
                    fprintf(stderr, "Unknown option %s.\n", [option UTF8String]);
                    exitCode = EXIT_UNKNOWN_OPTION;
                    break;
                case GBParseFlagMissingValue:
                    fprintf(stderr, "Missing value for option --%s.\n", [option UTF8String]);
                    exitCode = EXIT_FAILURE;
                    break;
                case GBParseFlagOption:
                    [settings setObject:value forKey:option];
                    break;
                case GBParseFlagArgument:
                    [settings addArgument:value];
                    break;
            }
        }];
        
        if (exitCode != EXIT_SUCCESS) {
            return exitCode;
        }
        
        Controller *controller = [[Controller alloc] init:(GBSettings *)settings];
        // processes options with controller, then returns with exit code
        return [controller processOptions];
    }
    
    return EXIT_SUCCESS;
}
