# k8s-letsencrypt
add, update wildcard ssl with let's encrypt in gcp

## 설명
gcp에서 letsencrypt 이용해서 wildcard ssl 인증서 추가 및 갱신

## 설치
```
- brew install gettext
- brew link gettext --force
```

## certbot 설정
```
- bash run.sh certbot [gcp_project id] [jwt path] [docker image repository] [email] [domain] [kubernetes namespace] [tls secret name]

```

## certbot 설정후 App Update(kubernetes ingress)
```
- bash run.sh update_app [domain] [namespace] [tls secret name] [kubernetes ingress global static ip name] [app service name]

```
