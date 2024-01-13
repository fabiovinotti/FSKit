# FSKit

FSKit is a small Swift library for interacting with the contents of the file system. It aims to provide a nicer API than those of FileManager and Foundation.

Right now FSKit is a work in progress and more work is needed to make it a complete file management solution.

## Installation

FSKit is a Swift package. To add it to your Xcode project:
<ol>
  <li>Go to File -> Add Packages...</li>
  <li>Enter <code>https://github.com/fabiovinotti/FSKit</code> in the search bar.</li>
  <li>Choose a dependency rule. "Up to Next Major Version" is the suggested setting.</li>
</ol>

## Getting Started with FSKit

### Files

Instances of the <code>File</code> class are used to manage regular files on the file system. <code>File</code> offers properties for accessing file attributes and methods for manipulating them.

#### Creating Files

FSKit allows you to create a new file at a certain path or URL. Optionally, a data object containing the contents of the new file can be provided.
```Swift
// Create a file at a path
let f1 = try File.create(at: "/Some/Path/file.txt")
        
// Create a file at a URL
let url = URL(fileURLWithPath: "/Another/Path/file.txt")
let f2 = try File.create(at: url)
        
// Create a file providing the contents of the new file
let fileData: Data = // Some data
let f3 = try File.create(at: "/Some/Path/file", contents: fileData)
```

#### Opening Files

A <code>File</code> object can be initialized with the path or URL of an existing regular file.
```Swift
let file = try File(at: "/Some/Path/file.txt")
```

### Directories

Instances of the <code>Directory</code> class are used to manage directories in the file system. <code>Directory</code> offers properties for accessing directory attributes and methods for manipulating directories and their contents.

#### Creating Directories

FSKit allows you to create a new directory at a certain path or URL.
```Swift
// Create a directory at a path
let directory = try Directory.create(at: "/Some/Path/Directory")

// Create a directory at a URL
let url = URL(fileURLWithPath: "/Some/Path/Directory")
let directory = try Directory.create(at: url)
```

#### Opening Directories

A new <code>Directory</code> object can be initialized with the path or URL of an existing directory.
```Swift
let directory = try Directory(at: "/Some/Path/Directory")
```

#### Managing Directory Contents

The <code>Directory</code> class has methods for inspecting its content and manipulating it.
```Swift
let directory = try Directory(at: "/Some/Path/Directory")
        
// Inspect contents
directory.containsItem(named: "file.txt")
        
// Get files in directory
let files: [File] = try directory.listFiles()
        
// Get subdirectories
let subdirs: [Directory] = try directory.listDirectories()

// Delete contents
try directory.deleteItem(named: "file.txt")
```

### Manipulating File System Items

Both <code>File</code> and <code>Directory</code> conform to the <code>FileSystemItem</code> protocol. It consists of a set of properties and methods relevant to any file system resource.
```Swift
let file = try File(at: "/Some/Path/file.txt")
let directory = try Directory(at: "/Some/Path/Dir")
        
// Copying file system items
try file.copy(to: "/Copy/Path/file.txt")
try directory.copy(to: "/Copy/Path/Dir")
        
// Moving file system items
try file.move(to: "/Move/Path/file.txt")
try directory.move(to: "/Move/Path/Dir")
```

### Handling Errors

All errors thrown in FSKit are of type <code>FSError</code> and have a property <code>localizedDescription</code> describing what went wrong.

## License

FSKit is available under the MIT license. See the LICENSE file for more info.
