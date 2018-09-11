# k8s-letsencrypt

## 설치
```
- brew install gettext
- brew link gettext --force
```


## certbot 설정
```
- bash run.sh certbot [docker repository] [email] [domain] [namespace] [secret] [ip name]

```

## certbot 설정후 App Update
```
- bash run.sh update_app [namespace] [ip name] [app service]

```