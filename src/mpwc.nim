import os, terminal
import masterpassword, cligen

type
  PassType = enum
    ptLong = "long", ptMedium = "medium", ptShort = "short",
    ptMaximum = "maximum", ptPin = "pin", ptBasic = "basic"

proc abort(s: string, c = 1) =
  stderr.writeLine s
  quit c

proc mpwc(
  pass = "",
  name = "",
  site = "",
  kind = ptLong,
  counter = 1,
  stdin = false
): int =

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
      pass = readPasswordFromStdin()
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
      of ptBasic: @templateBasic)
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


clCfg.version = "0.1.0"
dispatch mpwc,
  short = {"pass": 'p', "name": 'n', "site": 's', "kind": 'k', "counter": 'c',
           "stdin": 'S', "version": 'v'},
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
""",
    "counter": "site counter",
    "stdin": "read password from stdin",
  }
