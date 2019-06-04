# Package

version       = "0.1.0"
author        = "SolitudeSF"
description   = "Master Password command line utility"
license       = "MIT"
srcDir        = "src"
bin           = @["mpwc"]


# Dependencies

requires "nim >= 0.19.9", "masterpassword >= 0.1.0", "cligen >= 0.9.31"
