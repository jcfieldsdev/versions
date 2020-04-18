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

#import "File.h"

@implementation File

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    
    if (self != nil) {
        _URL = URL;
        _currentVersion = [NSFileVersion currentVersionOfItemAtURL:URL];
        _previousVersions = [NSFileVersion otherVersionsOfItemAtURL:URL];
    }

    return self;
}

- (BOOL)viewVersion:(NSUInteger)identifier error:(NSError **)errorPtr {
    NSUInteger index = [self.previousVersions count] - identifier;
    NSFileVersion *version = [self.previousVersions objectAtIndex:index];
    NSURL *URL = [version URL];
    
    NSData *contents = [[NSData alloc] initWithContentsOfURL:URL options:0 error:errorPtr];
    NSFileHandle *stdout = [NSFileHandle fileHandleWithStandardOutput];
    [stdout writeData:contents];
    
    return *errorPtr == nil;
}

- (BOOL)restoreVersion:(NSUInteger)identifier destination:(NSURL *)destination error:(NSError **)errorPtr {
    NSUInteger index = [self.previousVersions count] - identifier;
    NSFileVersion *version = [self.previousVersions objectAtIndex:index];
    [version replaceItemAtURL:destination options:0 error:errorPtr];
    
    return *errorPtr == nil;
}

- (BOOL)deleteVersion:(NSUInteger)identifier error:(NSError **)errorPtr {
    NSUInteger index = [self.previousVersions count] - identifier;
    NSFileVersion *version = [self.previousVersions objectAtIndex:index];
    return [version removeAndReturnError:errorPtr];
}

- (BOOL)deleteAllVersions:(NSError **)errorPtr {
    return [NSFileVersion removeOtherVersionsOfItemAtURL:self.URL error:errorPtr];
}

@end
