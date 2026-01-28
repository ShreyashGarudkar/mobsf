# Mobile Security Framework (MobSF)

![](https://cloud.githubusercontent.com/assets/4301109/20019521/cc61f7fc-a2f2-11e6-95f3-407030d9fdde.png)

Mobile Security Framework (MobSF) is a security research platform for mobile applications in Android, iOS and Windows Mobile. MobSF can be used for a variety of use cases such as mobile application security, penetration testing, malware analysis, and privacy analysis. The Static Analyzer supports popular mobile app binaries like APK, IPA, APPX and source code. Meanwhile, the Dynamic Analyzer supports both Android and iOS applications and offers a platform for interactive instrumented testing, runtime data and network traffic analysis. MobSF seamlessly integrates with your DevSecOps or CI/CD pipeline, facilitated by REST APIs and CLI tools, enhancing your security workflow with ease.


MobSF is also bundled with [Android Tamer](https://tamerplatform.com), [BlackArch](https://blackarch.org/mobile.html) and [Pentoo](https://www.pentoo.ch/).


## Documentation

Quick setup with docker

```
docker pull opensecurity/mobile-security-framework-mobsf:latest
docker run -it --rm -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest

# Default username and password: mobsf/mobsf
```

[![See MobSF Documentation](https://user-images.githubusercontent.com/4301109/70686099-3855f780-1c79-11ea-8141-899e39459da2.png)](https://mobsf.github.io/docs)

* Try MobSF Static Analyzer Online: [mobsf.live](https://mobsf.live)
* MobSF in CI/CD: [mobsfscan](https://github.com/MobSF/mobsfscan)
* Conference Presentations: [Slides & Videos](https://mobsf.github.io/Mobile-Security-Framework-MobSF/presentations.html)
* MobSF Online Course: [OpSecX MAS](https://opsecx.com/index.php/product/automated-mobile-application-security-assessment-with-mobsf/)
* What's New: [See Changelog](https://mobsf.github.io/Mobile-Security-Framework-MobSF/changelog.html)

## Collaborators
[karan_jondhale] | [rutvika_raskar] | [shubham_shinde] | [shreyash_garudkar]



## MobSF Support

* **Free Support:** Free limited support, questions, help and discussions, join our Slack channel [![Join_MobSF_Slack](https://img.shields.io/badge/mobsf%20slack-join-green?logo=slack&labelColor=4A154B)](https://join.slack.com/t/mobsf/shared_invite/zt-3ephptj6c-OuDMatJ9z9MT0T_Vb~l2pg)


### Static Analysis - Android

![mobsf_android_static_analysis](https://user-images.githubusercontent.com/4301109/95506503-f9b6c980-097d-11eb-803a-f88321e1feb7.gif)


### Dynamic Analysis - Android APK

![mobsf_android_dynamic_analysis](https://user-images.githubusercontent.com/4301109/95514697-5e782100-098a-11eb-8390-47bb3822a2d7.gif)

### Web API Viewer

![mobsf_web_api_fuzzing_with_burp](https://user-images.githubusercontent.com/4301109/95516560-69808080-098d-11eb-9e0b-fb5a25e96585.gif)