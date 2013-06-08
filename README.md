passo
=====

Tweet walk count! (retrieve walk data from fitbit api)

# Getting start
## 1. Generate .fitgem.yml
<pre>
$ cp sample.fitgem.yml .fitgem.yml
</pre>

コンシューマキーとコンシューマーシークレットを変更してください

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

# 参考
http://fitbitclient.com/guide/playing-with-the-fitgem-api
