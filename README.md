# Arista Dojo Lab

## Public Cloud (GCP) Setup

<br/>

1. Create a GCP account and attach payment method to get 300 USD free credit
   <br/>
   <br/>
2. Click on the project drop down (top left) to create a new project.
   <br/>
   <br/>
   ![Project drop down menu](https://storage.googleapis.com/aristadojo/images/proj-drop.png)
   <br/>
   <br/>
3. Click new project (top right)
   <br/>
   <br/>
   ![Project drop down menu](https://storage.googleapis.com/aristadojo/images/new-proj-button.png)
   <br/>
   <br/>
4. Select your new project from the project drop down (top left)
   <br/>
   <br/>
   ![Project drop down menu](https://storage.googleapis.com/aristadojo/images/select-new-proj.png)
   <br/>
   <br/>
5. Open GCP cloud shell (top right ">\_" button)
   <br/>
   <br/>
   ![Project drop down menu](ihttps://storage.googleapis.com/aristadojo/mages/cloud-shell-button.png)
   <br/>
   <br/>
6. You show now have a cloud shell open in the browser!
   <br/>
   <br/>
   ![Project drop down menu](https://storage.googleapis.com/aristadojo/images/cloud-shell.png)
   <br/>
   <br/>

You can now enter directly the following bash command into the cloud shell to setup your lab enviroment

### Setting Lab Configuration

Before running the Arista Dojo setup script you can optionally change some of the lab configurations. The defaults are listed below as are example or export alternative configuration values as cloud shell enviroment varibles.

#### Default Setting

- Region == europe-west2 (aka London)
- Firewall allowed src subnets == 0.0.0.0/0 (anyone can connect)


You might prefer to change some of these values. If so pick new values and copy and paste the "export" examples into your already open cloud shell.

#### Regions

- europe-west1 == Belgium
- europe-west2 == London
- europe-west3 == Frankfurt
- europe-west4 == Netherlands
- europe-west6 == Zurich
- europe-central2 == Poland

**NOTE:** The MY_IP_SUBNET value MUST end with a slash mask suffix.

Example env vars to change lab to run in Netherlands region and allow access to exposed ports from the src IP 1.2.3.4 (aka the IP of your current location)

```bash
export LAB_REGION=europe-west4
export MY_IP_SUBNET="1.2.3.4/32"
```

#### Running the Setup Script

1. You need to download the "setup.sh" script from the public Arista Dojo cloud storage bucket. The shell already has gsutil installed.

```bash
cd ~
gsutil cp gs://aristadojo/setup.sh ~/
chmod 700 setup.sh
ls -l setup.sh
```

<br/>

You may see a pop ask for authorization to allow the cloud shell to make GCP API called. Please click the 'Authorize' button

![cloud shell auth](https://storage.googleapis.com/aristadojo/images/auth-shell.png)

<br/>

After running the commands you should see ls command out put similar to the below (file size will vary)

<br/>

![ls output](https://storage.googleapis.com/aristadojo/images/setup-script-ls-output.png)

2. Invoke the setup script to create the eve-ng instance that hosts the Arista vEoS lab

```bash
~/setup.sh
```

**NOTE:** Select all devices in Eve-ng and choose start from the menu. It will take 5-10 mins for all devices to get to a ready state.

# Notes Public Image

The "aristadojo-eveng-v*" image that is used to build the eve-ng lab enviroment is maintained in a seperate GCP account and the follwing IAM policy binding are made to make the image available to other GCP accounts:

```bash
gcloud compute images add-iam-policy-binding aristadojo-eveng-v2 \
   --member='allAuthenticatedUsers' \
   --role='roles/compute.imageUser'
```

## OSX / MAC EVE-NG Client

https://www.eve-ng.net/index.php/download/
