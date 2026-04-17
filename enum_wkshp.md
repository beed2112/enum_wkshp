# OffSec Mentorship - Workshop - Enumeration Methodology






















### Agenda 

- Define 
- Passive 
- Active
- Commands
- Evolution of Process
- Docker lab
- HTB Server 



### Workshop Description

Enumeration is the process of systematically identifying and collecting information about a target system, network, or application, and serves as the bedrock of any successful offensive security assessment. In this hands-on workshop, we will explore both passive and active enumeration techniques, emphasizing their importance in the penetration testing lifecycle. Mentees will learn how to gather critical data—such as open ports, services, users, shares, and network structure—using industry-standard tools and methodologies.


### Workshop Objectives

- Understand the difference between passive and active enumeration, and when to use each approach
- Learn the methodology of thorough enumeration in offensive security engagements
- Gain practical experience with tools like Nmap and Netcat
- Practice structured note taking to support later stages of an assessment
- Discuss real-world scenarios where enumeration set the stage for successful exploitation


### What to Expect & Goal

This workshop is interactive and beginner-friendly. You’ll participate in guided exercises designed to build your confidence and proficiency with enumeration tools and techniques. By the end of the session, you’ll have a solid foundation in enumeration and be prepared for more advanced offensive security topics in future workshops.



### What is enumeration?

Enumeration is used to learn more about our target to understand the attack surface, identify potential weaknesses (vulnerabilities) that might expolited to achieve our goal.

- Enumeration is the collection of information on a set of targets, assets, or technologies.
- Properly enumerating an environment should make Penetration Testing or identifying vulnerabilities easier.
- Trying to reveal as much attack surface as possible.
- Enumeration can be done passively and actively.

Why is this important? 


### Passive and active enumeration - what's the difference?

1. Passive Enumeration - Building a dossier on the target
  a. Social Media
  b. shodan
  c. Whois
  d. Observation
  e. Listen (wireless/tcpdump/responder)

2. Active Enumeration - Executing commands to identify attack surface
  a. ping
  b. nmap
  c. gobuster/ffuf
  d. nc (banner grabbing)
  e. service specific tools


### What are some things we're hoping to find out by enumerating?

- Subdomains, ports, employer information (emails, logins), exposed passwords (data leaks)
- External attack surface
- Are they in the cloud?
- What type network architecture is in place?
- Do you have an up to date asset list?

### What are some common tools used to enumerate targets?

1. Network
- nmap
- masscan/rustscan - the children of nmap
- nc
- tcpdump - wireshark
- responder
- kismet
2. Web Application
- Directory/file discovery - gobuster/fuff/dirbuster 
- Web Browser Developer tools 
- Burpsuite
3. Service specific tools
- nxc
- snmpwalk
- ftp
- etc... 


### Nmap Discover Open TCP ports

Discover open TCP ports 

```
nmap -sS -Pn -n -T4  -oN ports.txt $TARGET

```
Options
- -sS SYN scan (half connect)  "stealthier" requires sudo
- -Pn Don't ping just scan  - ICMP sometimes blocked
- -n  No dns lookup "faster" less noise
- -T4 (-T[0-5]  speed/noise/accuracy
- -oN output file name 


| Timing | Speed      | Stealth | Accuracy | Typical Use |
|--------|-----------|--------|----------|-------------|
| T0     | 🔴 Very Slow | 🟢 High | 🟢 High | IDS evasion |
| T1     | 🔴 Slow     | 🟢 High | 🟢 High | Stealth scans |
| T2     | 🟡 Moderate | 🟡 Medium | 🟢 High | Production-safe |
| T3     | 🟢 Normal   | 🟡 Medium | 🟢 High | Default |
| T4     | 🟢 Fast     | 🔴 Low | 🟡 Medium | Pentesting / HTB |
| T5     | 🚀 Very Fast | 🔴 Very Low | 🔴 Lower | Speed over accuracy |



### Nmap Scan Open TCP ports

Scan open ports 

```
nmap -sS -sV -sC -Pn -n -T4 -p $(tr '\n' ',' < ports.txt | sed 's/,$//') -oA targeted_scan $TARGET

```

- -sS SYN scan (half connect)  "stealthier" requires sudo
- -sC run default and safe NSE scripts
- -sV try to determine service version 
- -Pn Don't ping just scan  - ICMP sometimes blocke
- -p  Scan just these ports
- -n  No dns lookup "faster" less noise
- -T4 (-T[0-5]  speed/noise/accuracy
- -oA output file name 


### Nmap Discover Open UDP ports

```
nmap -sU -Pn -n -T2 --top-ports 200 -oN udp_scan.txt $TARGET

```

- -sU UDP scan requires sudo
- -Pn Don't ping just scan  - ICMP sometimes blocke
- -n  No dns lookup "faster" less noise
- -T2 (-T[0-5]  UDP is flakey slow is better 
- --top-ports 200 - hit the most used ports - consider antother scan of more ports 
- -oN output file name 




### Nmap Scan Open UDP ports

```
nmap -sU -sV -Pn -n -T2 -p $(tr '\n' ',' < udp_ports.txt | sed 's/,$//') -oA udp_targeted $TARGET

```

- -sU UDP scan requires sudo
- -sC run default and safe NSE scripts
- -sV try to determine service version 
- -T2 (-T[0-5]  UDP is flakey slow is better 
- -Pn Don't ping just scan  - ICMP sometimes blocked
- -p  Scan just these ports
- -n  No dns lookup "faster" less noise
- -oA output file name 



### Figure out what is available to be enumerated "sweepers" 1.

There are times when you need to figure out what to scan:
- scan anything you want
- you are connected to a multi-homed machine 

Ping sweep time!

powershell

``` psh
1..254 | ForEach-Object -Parallel {
    $ip = "192.168.0.$_"
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
        "$ip is up"
    }
} -ThrottleLimit 50

```



### Figure out what is available to be enumerated "sweepers" 2.



Ping sweep time!

cmd.exe CLI

``` cmd
for /L %i in (1,1,254) do @ping -n 1 -w 300 192.168.0.%i >nul && echo alive: 192.168.0.%i

```


cmd.exe BAT extra %

``` cmd
for /L %%i in (1,1,254) do @ping -n 1 -w 300 192.168.0.%%i >nul && echo alive: 192.168.0.%%i

```

### Figure out what is available to be enumerated "sweepers" 3.



Ping sweep time!

bash

``` bash
for i in {1..254}; do   (ping -c 1 192.168.0.$i >/dev/null 2>&1 && echo "alive: 192.168.0.$i") ; done

```
xargs 

```bash
seq 1 254 | xargs -P 50 -I{} bash -c 'ping -c 1 -W 1 192.168.0.{} >/dev/null 2>&1 && echo 192.168.0.{}'

```


### Now that we found it -  "knockers" 1.

no nmap can't install it -- live off the land

powershell

```psh

$target = "192.168.0.253"

1..10000 | ForEach-Object {
    $port = $_
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($target, $port, $null, $null)
        $success = $iar.AsyncWaitHandle.WaitOne(100)

        if ($success -and $client.Connected) {
            Write-Host "OPEN: $target`:$port"
            $client.Close()
        }
    } catch {}
}

```


### Now that we found it -  "knockers" 2.



bash

```bash
for port in {1..10000}; do
  nc -zv 192.168.0.253 $port 2>&1 | grep succeeded
done

``` 
xargs

```bash
seq 1 10000 | xargs -P 50 -I{} bash -c 'nc -z -w1 192.168.0.252 {} 2>/dev/null && echo " {}"'

```

### Now that we found it -  "knockers" 3.

udp -- best effort doesn't get any better this way

```bash

nc -u -z -w1 192.168.0.250 161
Connection to 192.168.0.250 161 port [udp/snmp] succeeded!

```


### Evolution of the process 


Making life easier by complicating it  

- tee command 
- date `date +"%y-%m-%d %H:%M:%S"`
- aliases
- functions







### Let's play.


Will walk thru setting up a Docker container that we can use to get familiar with the process 



 
