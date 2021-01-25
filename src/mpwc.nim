import os, terminal, strutils
import masterpassword, cligen

type
  PassType = enum
    ptLong = "long", ptMedium = "medium", ptShort = "short",
    ptMaximum = "maximum", ptPin = "pin", ptBasic = "basic", ptLength = "length"

proc abort(s: string, c = 1) =
  stderr.writeLine s
  quit c

when defined(windows):
  from unicode import toUTF8, Rune, runeLenAt
  proc readPasswordFromStdin(pass: var string) =
    pass.setLen(0)
    while true:
      let c = getch()
      case c.char
      of '\r', chr(0xA):
        break
      of '\b':
        var i = 0
        var x = 1
        while i < pass.len:
          x = runeLenAt(pass, i)
          inc i, x
        pass.setLen(max(pass.len - x, 0))
      of chr(0x0):
        continue
      else:
        pass.add(toUTF8(c.Rune))

else:
  import termios
  proc readPasswordFromStdin(pass: var string) =
    pass.setLen(0)
    let fd = stdin.getFileHandle()
    var cur, old: Termios
    discard fd.tcgetattr(cur.addr)
    old = cur
    cur.c_lflag = cur.c_lflag and not Cflag(ECHO)
    discard fd.tcsetattr(TCSADRAIN, cur.addr)
    pass = stdin.readLine
    discard fd.tcsetattr(TCSADRAIN, old.addr)

proc mpwc(
  pass = "",
  name = "",
  site = "",
  kind = ptLong,
  counter = 1,
  length = 31,
  stdin = false
): int =

  if length <= 0 or length >= 32:
    abort "Password length must be between 1 and 31"

  let tty = system.stdin.isatty

  if stdin and tty:
    abort "stdin is connected to terminal"

  var
    pass = pass
    name = name
    site = site

  if pass.len == 0:
    if stdin:
      pass = system.stdin.readLine
    elif tty:
      stderr.write "password: "
      readPasswordFromStdin pass
      stderr.write "\n"
    if pass.len == 0:
      abort "Didn't specify the password"

  if name.len == 0:
    if existsEnv "MPW_FULLNAME":
      name = getEnv "MPW_FULLNAME"
    elif tty:
      stderr.write "name: "
      name = system.stdin.readLine
    if name.len == 0:
      abort "Didn't specify the name"

  if site.len == 0:
    if tty:
      stderr.write "site: "
      site = system.stdin.readLine
    if site.len == 0:
      abort "Didn't specify the site"

  let
    tmpl = (case kind
      of ptLong: @templateLong
      of ptMedium: @templateMedium
      of ptShort: @templateShort
      of ptMaximum: @templateMaximum
      of ptPin: @templatePin
      of ptBasic: @templateBasic
      of ptLength: @[
        if length >= 3:
          "ano" & 'x'.repeat(length - 3)
        else:
          "ano"[0..<length]
        ])

    icon = getIdenticon(pass, name)
    color = (case icon.color
      of 0: fgBlack
      of 1: fgRed
      of 2: fgGreen
      of 3: fgYellow
      of 4: fgBlue
      of 5: fgMagenta
      of 6: fgCyan
      of 7: fgWhite
      else: fgDefault)

  stderr.styledWrite "[ ", color, $icon, fgDefault ," ]: "
  stdout.write getSitePass(getSiteKey(getMasterKey(pass, name), site, counter), tmpl)
  if stdout.isatty: stdout.writeLine ""


clCfg.version = "0.1.3"
dispatch mpwc,
  short = {"pass": 'p', "name": 'n', "site": 's', "kind": 'k', "counter": 'c',
           "stdin": 'S', "length": 'l', "version": 'v'},
  help = {
    "pass": "master password",
    "name": "full name",
    "site": "target site",
    "kind": """type of a password:
maximum | 20 characters, contains symbols.
long    | 14 characters, symbols.
medium  | 8 characters, symbols.
basic   | 8 characters, no symbols.
short   | 4 characters, no symbols.
pin     | 4 numbers.
length  | length specified by --length option,
        | maximum 31 characters, symbols.
""",
    "counter": "site counter",
    "stdin": "read password from stdin",
  }
