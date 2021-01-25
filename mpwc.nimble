# Package

version       = "0.1.3"
author        = "SolitudeSF"
description   = "Master Password command line utility"
license       = "MIT"
srcDir        = "src"
bin           = @["mpwc"]


# Dependencies

requires "nim >= 1.0.0", "masterpassword >= 0.2.0", "cligen >= 1.0.0"
