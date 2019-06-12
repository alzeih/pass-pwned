# pass-pwned
[Password-Store](https://www.passwordstore.org/) extension for [Have I Been Pwned?](https://haveibeenpwned.com/) Pwned Passwords v2 API

This extension uses Troy Hunt's Have I Been Pwned? API <https://haveibeenpwned.com/API/v2>

> In order to protect the value of the source password being searched for,
> Pwned Passwords also implements a k-Anonymity model that allows a password
> to be searched for by partial hash. This allows the first 5 characters of a
> SHA-1 password hash (not case-sensitive) to be passed to the API
> <https://haveibeenpwned.com/API/v2#SearchingPwnedPasswordsByRange>

## Installation
For general password-store extension installation instructions see <https://www.passwordstore.org/#extensions>

### Distribution install

Fedora 29 and beyond have pass-pwned packaged.  You can install the package with:

`sudo dnf install pass-pwned`

### Manual install as current user

```
 echo 'export PASSWORD_STORE_ENABLE_EXTENSIONS="true"' >> ~/.bash_profile
 source ~/.bash_profile
 curl https://raw.githubusercontent.com/alzeih/pass-pwned/master/pwned.bash -O ~/.password-store/.extensions/pwned.bash
 chmod u+x ~/.password-store/.extensions/pwned.bash
```

## Usage

```
 $ pass pwned <pass-name>
   Password found in haveibeenpwned 3303003 times

 $ pass pwned <pass-name>
   Password not found in haveibeenpwned
```

## Contributing

This project has a [Contributor Covenant Code of Conduct](https://github.com/alzeih/pass-pwned/blob/master/CODE_OF_CONDUCT.md).

* [Code](https://github.com/alzeih/pass-pwned)
* [Issues](https://github.com/alzeih/pass-pwned/issues)
* [Pull Requests](https://github.com/alzeih/pass-pwned/pulls)
* [Wiki](https://github.com/alzeih/pass-pwned/wiki)

## License

[MIT Licence](https://github.com/alzeih/pass-pwned/blob/master/LICENSE)

API Service by Have I Been Pwned? <https://haveibeenpwned.com/> under the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
