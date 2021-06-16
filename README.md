# Arista Dojo Lab Setup

## Public Cloud (GCP) Account Creation

<br/>

1. Create a GCP account and attach payment method to get 300 USD free credit.

   https://console.cloud.google.com
   <br/>

2. Click on activate (top right), agree to terms of service and set country, contact info, add credit card info etc. Short survey on why you are creating account. $300 USD credit is good for 90 days.
   <br/>
   <br/>
   ![activate button](images/activate.png)

   <br/>
   <br/>

3. Click on the project drop down (top left) to create a new project.
   <br/>
   <br/>
   ![Project drop down menu](images/proj-drop.png)
   <br/>
   <br/>

4. Click new project (top right)
   <br/>
   <br/>
   ![Project drop down menu](images/new-proj-button.png)
   <br/>
   <br/>

5. Name new project, "Create button"
   <br/>
   <br/>
   ![Project drop down menu](images/name-new-proj.png)
   <br/>
   <br/>

6. Click either on "Home" menu (left side), project drop down will appear.
   <br/>
   <br/>
   ![click home menu](images/home-menu.png)
   <br/>
   <br/>
7. Click drop down (top left)
   <br/>
   <br/>
   ![click Project drop down menu](images/proj-drop.png)
   <br/>
   <br/>

8. Select the newly create project "AristLab" for example, click "Open".
   <br/>
   <br/>
   ![select new project](images/select-new-proj.png)
   <br/>
   <br/>

9. Verify that project (top left) is now shown as the new project. Then open GCP cloud shell (clickl top right ">\_" button)
   <br/>
   <br/>
   ![cloudshell button](images/set-to-new-proj.png)
   <br/>
   <br/>
   ![cloudshell button](images/cloud-shell-button.png)

   <br/>
   <br/>
10. Click "Continue" to start cloudshell for the first time
    <br/>
    <br/>
    ![Project drop down menu](images/first-cloudshell.png)
    <br/>
    <br/>
11. You show now have a cloud shell open in the browser!
    <br/>
    <br/>
    ![Project drop down menu](images/cloud-shell.png)
    <br/>
    <br/>

<br/>

**You can now enter directly the following bash command into the cloud shell to setup your lab enviroment**

<br/>
<br/>

---

<br/>
<br/>

## Setup from Git Repo

Paste the follow bash commands into the cloudshell, see example out.

```bash
git clone https://github.com/bodleytunes/arista-dojo.git
cd arista-dojo
```

<br/>

![git clone](images/git-clone.png)
<br/>
<br/>

Before running the Arista Dojo setup script you can optionally change some of the lab configurations. The defaults are listed below, as well as example alternative configuration values.

Alternative values are export as shell enviroment varibles, see below.

### Default Setting and Alternatives

- LAB_REGION == europe-west2 (aka London)
- MY_IP_SUBNET == 0.0.0.0/0 (anyone can connect)
- MACHINE_TYPE == n2-standard-4 (4vcpu, 16GB)


You might prefer to change some of these values. If so pick new values and copy and paste the "export" examples into your already open cloud shell.

### Region Examples

- europe-west1 == Belgium
- europe-west2 == London
- europe-west3 == Frankfurt
- europe-west4 == Netherlands
- europe-west6 == Zurich
- europe-central2 == Poland

### Machine-type examples

- n2-standard-2 == 2 vcpu and 8GB RAM
- n2-standard-8 == 8 vcpu and 32GB RAM


**NOTE:** The MY_IP_SUBNET value MUST end with a slash mask suffix.

Example env vars to change lab to run in Netherlands region and allow access to exposed ports from the src IP 1.2.3.4 (aka the IP of your current location)

```bash
export LAB_REGION=europe-west4
export MY_IP_SUBNET=1.2.3.4/32
export MACHINE_TYPE=n2-standard-8
```

<br/>

### Running the Setup Script

<br/>

1. From inside the clone git repository execute the "install-dojo.sh" bash script

```bash
cd ~/arista-dojo
ls -l
./install-dojo.sh
```

<br/>

You may see a pop up asking for authorization to allow the cloud shell to make GCP API called. Please click the 'Authorize' button. You

![cloud shell auth](images/auth-shell.png)

<br/>

If prompted, answer "y" to enable the GCP compute engine API, to allow the create of VM instance to support the EVE-NG lab.

![cloud shell auth](images/setup-script.png)

<br/>


The install will continue, start a VM instance and set up firewalls to the EVE-NG lab instance. If you didn't set a MY_IP_SUBNET env var then anyone on the internet will be able to access the instance.

![cloud shell auth](images/install-finish.png)

<br/>

## Setup Auto Cleaup of Instance

Run the "cleanup.sh" script to setup a automated process to kill the eve-ng VM every day at 23:00 UTC. If you remove the label "ttl:24h" the VM will not be cleaned up.

```bash
cd ~/arista-dojo
./cleanup.sh
```

## Connect to EVE-NG WEB GUI

The below command shows you the public IP that the EVE-NG GUI is hosted on (http://34.76.90.27 , per the example output below).

```bash
gcloud compute instances describe eve-ng | grep natIP
```


<br/>

![cloud shell auth](images/natIP.png)

<br/>




**NOTE:** Select all devices in Eve-ng and choose start from the menu. It will take 5-10 mins for all devices to get to a ready state.

# Notes Public Image

The "aristadojo-eveng-v\*" image that is used to build the eve-ng lab enviroment is maintained in a seperate GCP account and the follwing IAM policy binding are made to make the image available to other GCP accounts:

```bash
gcloud compute images add-iam-policy-binding aristadojo-eveng-v3 \
   --member='allAuthenticatedUsers' \
   --role='roles/compute.imageUser'
```

## OSX / MAC EVE-NG Client

https://www.eve-ng.net/index.php/download/
