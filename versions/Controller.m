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

#import "Controller.h"

@implementation Controller

- (instancetype)init:(GBSettings *)settings {
    self = [super init];
    
    if (self != nil) {
        // array of file arguments
        _files = [settings arguments];
        
        // options
        // booleans
        _help = [settings boolForKey:@"help"];
        _deleteAll = [settings boolForKey:@"deleteAll"];
        // integers
        _viewVersion = [settings unsignedIntegerForKey:@"view"];
        _restoreVersion = [settings unsignedIntegerForKey:@"restore"];
        _replaceVersion = [settings unsignedIntegerForKey:@"replace"];
        _deleteVersion = [settings unsignedIntegerForKey:@"delete"];
    }

    return self;
}

- (int)processOptions {
    // prints help if --help option used or no file arguments passed
    if (self.help || [self.files count] == 0) {
        [self printHelp];
        return EXIT_SUCCESS;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *baseURL = [NSURL fileURLWithPath:[fileManager currentDirectoryPath]];
    _source = [NSURL fileURLWithPath:[self.files firstObject] relativeToURL:baseURL];
    
    NSError *error = nil;
    
    // file does not exist/unreachable (also fails on non-file URLs)
    if (![self.source checkResourceIsReachableAndReturnError:&error]) {
        fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
        return EXIT_FAILURE;
    }
    
    _file = [[File alloc] initWithURL:self.source];
    
    // saves destination URL if specified
    if ([self.files count] > 1) {
        _destination = [NSURL fileURLWithPath:[self.files objectAtIndex:1] relativeToURL:baseURL];
    }
    
    if (self.viewVersion) {
        return [self doViewVersion];
    }
    
    if (self.restoreVersion) {
        return [self doRestoreVersion];
    }
    
    if (self.replaceVersion) {
        return [self doReplaceVersion];
    }
    
    if (self.deleteVersion) {
        return [self doDeleteVersion];
    }
    
    if (self.deleteAll) {
        return [self doDeleteAll];
    }
    
    [self printVersions];
    return EXIT_SUCCESS;
}

- (void)printHelp {
    puts("Usage: versions [option] source_file [destination_file]\n");
    puts("If no option given, lists all versions of the source file with identifiers.\n");
    puts("View options:");
    puts("--view <identifier>    View the previous version of given identifier.\n");
    puts("Restore options:");
    puts("--restore <identifier> Restore the previous version of given identifier to a");
    puts("                       new file. Requires a second file argument for the");
    puts("                       destination file.");
    puts("--replace <identifier> Replace the file with the previous version of given");
    puts("                       identifier.\n");
    puts("Delete options:");
    puts("--delete <identifier>  Delete the previous version of given identifier.");
    puts("--deleteAll            Delete all previous versions.");
}

- (void)printVersions {
    if ([self.file.previousVersions count] == 0) {
        printf("No previous versions of file %s.\n", [[self.source lastPathComponent] UTF8String]);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    
    NSUInteger index = 0;
    
    for (NSFileVersion *version in self.file.previousVersions) {
        NSUInteger identifier = [self.file.previousVersions count] - index;
        NSString *date = [dateFormatter stringFromDate:[version modificationDate]];
        NSString *fileName = [version localizedName];
        
        printf("[%3lu] %-30s %s\n", identifier, [date UTF8String], [fileName UTF8String]);
        index++;
    }
    
    NSString *date = [dateFormatter stringFromDate:[self.file.currentVersion modificationDate]];
    NSString *fileName = [self.file.currentVersion localizedName];
    
    // prints current version as 0
    printf("[%3d] %-30s %s\n", 0, [date UTF8String], [fileName UTF8String]);
}

- (int)doViewVersion {
    NSUInteger identifier = self.viewVersion;
    
    if (identifier > [self.file.previousVersions count]) {
        fprintf(stderr, "Invalid version %lu.\n", identifier);
        return EXIT_FAILURE;
    }
    
    NSError *error = nil;
    BOOL success = [self.file viewVersion:identifier error:&error];
    
    if (!success) {
        fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}

- (int)doRestoreVersion {
    NSUInteger identifier = self.restoreVersion;
    
    if (identifier > [self.file.previousVersions count]) {
        fprintf(stderr, "Invalid version %lu.\n", identifier);
        return EXIT_FAILURE;
    }
    
    if (self.destination == nil) {
        fprintf(stderr, "Not enough arguments. Must provide a destination file name or use the --replace option to replace the current file.\n");
        return EXIT_FAILURE;
    }

    NSError *error = nil;
    BOOL success = [self.file restoreVersion:identifier destination:self.destination error:&error];
    
    if (!success) {
        fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
        return EXIT_FAILURE;
    }
    
    printf("Successfully restored version %lu of %s to %s.\n",
        identifier,
        [[self.source lastPathComponent] UTF8String],
        [[self.destination lastPathComponent] UTF8String]
    );
    return EXIT_SUCCESS;
}

- (int)doReplaceVersion {
    NSUInteger identifier = self.replaceVersion;
    
    if (identifier > [self.file.previousVersions count]) {
        fprintf(stderr, "Invalid version %lu.\n", identifier);
        return EXIT_FAILURE;
    }
    
    if (self.destination != nil) { // safety check
        fprintf(stderr, "Too many arguments. Use the --restore option to restore a version to a new file.\n");
        return EXIT_FAILURE;
    }

    NSError *error = nil;
    BOOL success = [self.file restoreVersion:identifier destination:self.source error:&error];
    
    if (!success) {
        fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
        return EXIT_FAILURE;
    }
    
    printf("Successfully restored version %lu of %s.\n",
        identifier,
        [[self.source lastPathComponent] UTF8String]
    );
    return EXIT_SUCCESS;
}

- (int)doDeleteVersion {
    NSUInteger identifier = self.deleteVersion;
    
    if (identifier > [self.file.previousVersions count]) {
        fprintf(stderr, "Invalid version %lu.\n", identifier);
        return EXIT_FAILURE;
    }
    
    NSError *error = nil;
    BOOL success = [self.file deleteVersion:identifier error:&error];
    
    if (!success) {
        fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
        return EXIT_FAILURE;
    }
    
    printf("Successfully deleted version %lu of %s.\n",
        identifier,
        [[self.source lastPathComponent] UTF8String]
    );
    return EXIT_SUCCESS;
}

- (int)doDeleteAll {
    NSError *error = nil;
    BOOL success = [self.file deleteAllVersions:&error];
    
    if (!success) {
        fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
        return EXIT_FAILURE;
    }
    
    printf("Successfully deleted all previous versions of %s.\n",
        [[self.source lastPathComponent] UTF8String]
    );
    return EXIT_SUCCESS;
}

@end
