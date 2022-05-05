# Weather Forecaster

<div align="center">
    <img src="./figures/why_does_this_always_happen.jpg" width="400px">
</div>

Humans have seen the sky and if it's getting cloudy, they think it's going to rain soon.
If clouds get sparser, we think it will be sunny tomorrow.

I want to try to apply this simple logic to trading.

----

MetaTradorのプロジェクトをシンボリックリンクで別の場所に貼って、それをGitで管理したかったが、GitHubでは実体を表示してくれなかったりしてうまく行かない。
対処として、`~/.wine/drive_c/Program Files (x86)/XMTrading MT4/MQL4/Experts/`にプロジェクトを作り、
それを直接Gitで管理するようにしてみようと思う。（つまり`~/.wine/drive_c/Program Files (x86)/XMTrading MT4/MQL4/Experts/`に例えば`Cloudiness/`というプロジェクトを作り、その下に`.git/`があって、これらをGitで管理するような仕組み。）