passo - Tweet your passo!
=====

passo は，fitbit のアクティビティ情報を取得し，1000歩ごとにTwitterにつぶやくプログラムです．
passo retrieves walk steps from fitbit api.
    
# 動作環境
- ruby 1.9.2 or later

# 利用ライブラリ

下記のライブラリを利用しています．ありがとうございます．

* gem
  * twitter
  * fitgem


# Getting start

## 0. 準備

事前に twitter および fitbit api にて oauth の各情報を取得しておく必要があります．
(TODO: 追記)

## 1. Generate .fitgem.yml
<pre>
$ cp sample.fitgem.yml .fitgem.yml
</pre>

comsumer_key と consumer_secret を変更してください

## 2. bundle install
<pre>
$ bundle install
</pre>

## 3. 手動実行
fitbit api 利用のための認証が必要ですので，手動実行します．

<pre>
$ ruby passo.rb
</pre>

URL が表示されると思いますので，ブラウザでアクセスします．
次に，ブラウザに表示されたキーを，端末に入力してください．

## 4. Add cron

### Case. 通常のruby環境
<pre>
$ crontab -e
* * * * * ruby /path/to/passo/passo.rb >> /path/to/passo.log 2>&1
</pre>

### Case. rvm 環境
rvm用 shell script がありますのでそちらを cron に設定してください

<pre>
$ crontab -e
* * * * * bash /path/to/passo/kick.sh >> /path/to/passo.log 2>&1
</pre>

# License & Copyright
MIT License, Copyright (c) 2013 @isseium 

# 参考
http://fitbitclient.com/guide/playing-with-the-fitgem-api
