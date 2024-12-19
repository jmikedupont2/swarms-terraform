
# credentials

set up ~/.aws/credentials
```
[swarms]
aws_access_key_id =${your key}
aws_secret_access_key=${your SECRET}
```

# install opentofu or terraform
# install aws cli
# install aws ssm plugin

# create openai secret token

TODO:
`aws ssm set-parameter     --name "swarms_openai_key"`

# tofu init
# tofu plan
# tofu apply
point the dns api.swarms.ai at the dns servers in godaddy

`tofu state show module.swarms_api.module.alb.module.route53.data.aws_route53_zone.primary`

```terraform
# module.swarms_api.module.alb.module.route53.data.aws_route53_zone.primary:
data "aws_route53_zone" "primary" {
    arn                       = "arn:aws:route53:::hostedzone/Z04162952OP7P14Z97UWY"
    caller_reference          = "937599df-113d-4b02-8c75-4a20f8e6293e"
    id                        = "Z04162952OP7P14Z97UWY"
    name                      = "api.swarms.ai"
    name_servers              = [
        "ns-864.awsdns-44.net",
        "ns-1595.awsdns-07.co.uk",
        "ns-1331.awsdns-38.org",
        "ns-463.awsdns-57.com",
    ]
    primary_name_server       = "ns-864.awsdns-44.net"
    private_zone              = false
    resource_record_set_count = 3
    tags                      = {}
    zone_id                   = "Z04162952OP7P14Z97UWY"
}
```
so we need 4 records

1. NS api.swarms.ai -> "ns-864.awsdns-44.net"
2. NS api.swarms.ai -> "ns-1595.awsdns-07.co.uk"
3. NS api.swarms.ai -> "ns-1331.awsdns-38.org"
4. NS api.swarms.ai -> "ns-463.awsdns-57.com"

see forum  https://repost.aws/questions/QULXL3STgjQtefiJ_q0BixXA/configure-godaddy-subdomain-to-route53

it says ns records need fqdn!

```
dig NS api.swarms.ai @97.74.103.14

; <<>> DiG 9.18.28-0ubuntu0.22.04.1-Ubuntu <<>> NS api.swarms.ai @97.74.103.14
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 42722
;; flags: qr rd; QUERY: 1, ANSWER: 0, AUTHORITY: 4, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;api.swarms.ai.			IN	NS

;; AUTHORITY SECTION:
api.swarms.ai.		3600	IN	NS	ns-1912.awsdns-47.co.uk.
api.swarms.ai.		3600	IN	NS	ns-184.awsdns-23.com.
api.swarms.ai.		3600	IN	NS	ns-598.awsdns-10.net.
api.swarms.ai.		3600	IN	NS	ns-1175.awsdns-18.org.

;; Query time: 5 msec
;; SERVER: 97.74.103.14#53(97.74.103.14) (UDP)
;; WHEN: Wed Dec 18 09:20:45 EST 2024
;; MSG SIZE  rcvd: 182
```

```
mdupont@mdupont-G470:~/swarms-terraform/accounts/swarms$ dig NS api.swarms.ai +trace

; <<>> DiG 9.18.28-0ubuntu0.22.04.1-Ubuntu <<>> NS api.swarms.ai +trace
;; global options: +cmd
.			198100	IN	NS	b.root-servers.net.
.			198100	IN	NS	j.root-servers.net.
.			198100	IN	NS	a.root-servers.net.
.			198100	IN	NS	d.root-servers.net.
.			198100	IN	NS	c.root-servers.net.
.			198100	IN	NS	g.root-servers.net.
.			198100	IN	NS	l.root-servers.net.
.			198100	IN	NS	i.root-servers.net.
.			198100	IN	NS	h.root-servers.net.
.			198100	IN	NS	f.root-servers.net.
.			198100	IN	NS	e.root-servers.net.
.			198100	IN	NS	m.root-servers.net.
.			198100	IN	NS	k.root-servers.net.
;; Received 811 bytes from 127.0.0.53#53(127.0.0.53) in 10 ms

ai.			172800	IN	NS	v0n0.nic.ai.
ai.			172800	IN	NS	v0n1.nic.ai.
ai.			172800	IN	NS	v0n2.nic.ai.
ai.			172800	IN	NS	v0n3.nic.ai.
ai.			172800	IN	NS	v2n0.nic.ai.
ai.			172800	IN	NS	v2n1.nic.ai.
ai.			86400	IN	DS	44137 8 2 7886BD35ED745DCA983D951A643495B929B3A7676A88C682EF88EB6F EDBDB253
ai.			86400	IN	DS	3799 8 2 8A8030D4661AE6FCF417349682AC058648371002E70E717E4CF2F11F 83543385
ai.			86400	IN	RRSIG	DS 8 1 86400 20241231050000 20241218040000 61050 . chqcZJHy4mAsB6DryQAHcvFBsUDVkhHQStDq65NbEXoeo+sfNsRWVpGV qyibbDL8nLY0QDOifh5EXu1Mnf6ZXqs8NPaPBEwCpA9oVmRA0t3vG2th jrDhKY77f4iL4ovMQLBSYbF5x61HnFZXcgyI22YDbbChsC6rCwmNJnwj sldGSNknyRy4ytEwbsWYquRmXIzSHJ2O9lMw1l/vUHpw9/xo6k26TyhZ 3bydt6Sg/e56zwevU0oW1sRpR9aKwn4x/0X0txKmUo+2wWtJr/GXLJ28 uWIuEF71Tvg2QKM0XqZ2CLeURCkU3v4sV92vKQ3rY0GkMiKKlWYFaC8Q Ev4+0A==
;; Received 807 bytes from 199.7.91.13#53(d.root-servers.net) in 11 ms

;; communications error to 2001:500:a4::1#53: timed out
;; communications error to 2001:500:a4::1#53: timed out
;; communications error to 2001:500:a4::1#53: timed out
;; communications error to 2001:500:a1::1#53: timed out
;; communications error to 2001:500:a2::1#53: timed out
;; communications error to 2001:500:a5::1#53: timed out
swarms.ai.		3600	IN	NS	ns27.domaincontrol.com.
swarms.ai.		3600	IN	NS	ns28.domaincontrol.com.
58cj07tk4r4uuu6m10c83sia655jfil6.ai. 86400 IN NSEC3 1 1 0 73 58MDDLU23QVIIIQ5GPLB3A6K7OB4F5JH NS SOA TXT RRSIG DNSKEY NSEC3PARAM ZONEMD
jib3vggauf3u1alb3kfuqrcjo6a0v2hq.ai. 86400 IN NSEC3 1 1 0 73 JIGGLMUFEJ6D5CFLQAC5CFQICTP7IJTE NS DS RRSIG
58cj07tk4r4uuu6m10c83sia655jfil6.ai. 86400 IN RRSIG NSEC3 8 2 86400 20250108141827 20241218131827 6279 ai. r8VEiuIyhowQ2sXxszJEgCBMnMEkyboj418iO/jJfUKxWM408IJTSiuO aALz97JNhHMyzPxScRCO+Vcr3EOuoBknhiO5oO9w7UDnuzxNRyPuevV6 WdloLDUc3GRKSPxWom4/Dh+yaMTBXr2xiDDpIvmAElU5q1oGceB+5wWf 4i4=
jib3vggauf3u1alb3kfuqrcjo6a0v2hq.ai. 86400 IN RRSIG NSEC3 8 2 86400 20250107151955 20241217141955 6279 ai. vyYgTKyNXo+kYzRoc0zYeR544efw1GPI4br3GtS4lRaUwzc3sEFKtoyo /nNGBWKgnYxlWyhrAgTvCQTLO1Qt6uJWyHVcog+6hcVcbeFsL6whp/u8 LKHOtSFg2C/FzqP3JktiSPO5CcQh6WiBik2KXhkD00lMjXfStciqk9nP osk=
;; Received 583 bytes from 199.115.156.1#53(v2n0.nic.ai) in 22 ms

api.swarms.ai.		3600	IN	NS	ns-1912.awsdns-47.co.uk.
api.swarms.ai.		3600	IN	NS	ns-184.awsdns-23.com.
api.swarms.ai.		3600	IN	NS	ns-598.awsdns-10.net.
api.swarms.ai.		3600	IN	NS	ns-1175.awsdns-18.org.
;; Received 182 bytes from 173.201.71.14#53(ns28.domaincontrol.com) in 5 ms

;; Received 31 bytes from 205.251.199.120#53(ns-1912.awsdns-47.co.uk) in 4 ms
```

https://toolbox.googleapps.com/apps/dig/#ANY/ returns 
for swarms.ai this:
```
id 44700
opcode QUERY
rcode NOERROR
flags QR RD RA
;QUESTION
swarms.ai. IN ANY
;ANSWER
swarms.ai. 3600 IN A 15.197.225.128
swarms.ai. 3600 IN A 3.33.251.168
swarms.ai. 3600 IN NS ns28.domaincontrol.com.
swarms.ai. 3600 IN NS ns27.domaincontrol.com.
swarms.ai. 3600 IN SOA ns27.domaincontrol.com. dns.jomax.net. 2024121702 28800 7200 604800 600
swarms.ai. 3600 IN TXT "google-site-verification=VlUvNHJo0LQzJzm7SIwMzYLB7-Rexx4yxcSJKh0VtjE"
;AUTHORITY
;ADDITIONAL
```

# tofu apply

`tofu apply`
