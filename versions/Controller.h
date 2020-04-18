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
#import "File.h"

NS_ASSUME_NONNULL_BEGIN

@interface Controller : NSObject

@property(retain) NSArray *files;
@property(retain) File *file;
@property(retain) NSURL *source;
@property(retain) NSURL *destination;
@property(assign) BOOL help;
@property(assign) BOOL deleteAll;
@property(assign) NSUInteger viewVersion;
@property(assign) NSUInteger restoreVersion;
@property(assign) NSUInteger replaceVersion;
@property(assign) NSUInteger deleteVersion;

- (instancetype)init:(GBSettings *)settings;
- (int)processOptions;
- (void)printHelp;
- (void)printVersions;
- (int)doViewVersion;
- (int)doRestoreVersion;
- (int)doReplaceVersion;
- (int)doDeleteVersion;
- (int)doDeleteAll;

@end

NS_ASSUME_NONNULL_END
