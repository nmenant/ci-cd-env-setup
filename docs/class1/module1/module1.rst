Module 1 - Review the setup 
===========================

In this module, we will show you how to do a demo of IaC (*Infrastructure as Code*) 
with F5 solutions: 

* We will use GitLab to host our application definition and 
  also services tied to it : *ADC* and *Web Application Firewall* services
* We will trigger our CI/CD *pipeline* by updating our *Gitlab* repo 
* We will monitor how our application is deployed. 
* We will ensure that the relevant *ADC* services are deployed on our *BIG-IP*

To do this demo, we need to get a proper understanding of the setup. 

Through Module1, you'll review the overall setup and be able to trigger a demo of IaC

You have a preso you can use/review to see the overall workflow, Here is the Preso_. 

.. _Preso: https://github.com/nmenant/ci-cd-env-setup/blob/master/docs/Preso/CI-CD%20Local%20Demo.pptx

Here is the workflow of the solution: 

#. We leverage a *GitLab* repo called **my-webapp-ci-cd-demo** that contains our app definition and the *ADC Services* tied to it. 
#. We update this repo to trigger a *WebHook* that will ask our CI Server to retrieve this repo and process its *jenkinsFile*
#. Our CI server will do the following: 
   
  * retrieve the repo
  * deploy the app based on its definition
  * test that the app is up and running based on the tests defined in the repo
  * review the *ADC services* definition in the repo and ensure its fine. 
  * Update another repo called **ADC-Services** to add its ADC service definition and the tests to validate its proper deployment

#. Since we updated our **ADC-Services** repo on *GitLab*, it will also send a *WebHook* to *Jenkins* to trigger another *pipeline*

#. Our CI server will execute the relevant pipeline that will do the following: 

  * review the commit log to know which app has been added
  * find in which cluster this app has been added
  * review and put all the app services for this cluster in a single AS3 declaration
  * Test this tenant definition against the relevant cluster
  * Deploy this declaration 
  * Trigger the tests tied to this app through BIG-IP to make sure it is still successfull

**Exercises in this Module**

.. toctree::
   :maxdepth: 1
   :glob:

   lab*