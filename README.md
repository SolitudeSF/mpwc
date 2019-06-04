# mpwc

Stateless password manager using [Master Password algorithm](https://masterpassword.app/masterpassword-algorithm.pdf).

## Installation

`nimble install mpwc`

Requires `libsodium` installed.

## Example usage

`mpwc -p "probably not the best way to supply a password" -n $(whoami) -s github`

If not provided as command line arguments, password, name and site are prompted in the terminal:

```
$ mpwc
password:
name: SolitudeSF
site: github
[ ═☻═⚔  ]: thisisit
```

If enviroment variable `MPW_FULLNAME` is set then the name is read from it.

You can use `--stdin` flag to read the password from `stdin`:

```
gpg2 -d -q "password.gpg" | mpwc --stdin -n me -s ssh
```
