function Calc()
{
	python3 -c "print( $* )"
}

function Q()
{
	alias urlencode='python3 -c "import sys, urllib.parse as ul; \
    print (ul.quote_plus(sys.argv[1]))"'
	
	firefox --new-tab "https://www.google.com/search?q=$(urlencode "$*")"	
}
. "/home/davawen/.local/share/cargo/env"
