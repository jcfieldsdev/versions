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

NS_ASSUME_NONNULL_BEGIN

@interface File : NSObject

@property(copy) NSURL *URL;
@property(retain) NSFileVersion *currentVersion;
@property(retain) NSArray *previousVersions;

- (instancetype)initWithURL:(NSURL *)URL;
- (BOOL)viewVersion:(NSUInteger)identifier error:(NSError **)errorPtr;
- (BOOL)restoreVersion:(NSUInteger)identifier destination:(NSURL *)destination error:(NSError **)errorPtr;
- (BOOL)deleteVersion:(NSUInteger)identifier error:(NSError **)errorPtr;
- (BOOL)deleteAllVersions:(NSError **)errorPtr;

@end

NS_ASSUME_NONNULL_END
