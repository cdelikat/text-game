
#socat TCP-LISTEN:2500,fork EXEC:"/usr/bin/sbcl"
socat TCP-LISTEN:2500,fork EXEC:"./start.sh"
