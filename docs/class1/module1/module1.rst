Module 1 - Do an IaC Demo
=========================

In this module, we will show how to do a demonstration of IaC: 

* We will use GitLab to host our application definition and also services tied to it :
    ADC and Web Application Firewall services
* We will trigger our CI/CD pipeline by updating Gitlab 
* We will monitor how our application is deployed. 

To do this demo, we need to get a proper understanding of the setup. 

Gitlab setup
------------

We have setup the following in GitLab: 

* A Tenant/User called **TenantA**. It host all the applications and adc services tied to this tenant.
    You can have multiple applications owned by this user and multiple BIG-IP/ADC services here. 
* For this demo, we will use two different repos in **TenantA**: *my-webapp-ci-cd-demo* and *ADC-Services* 

.. image:: ../../_static/class1/module1/001.png
    :align: center
    :scale: 50%

**my-webapp-ci-cd-demo** contains the application definition and the **ADC Services** we want to attach to it. 
It leverages the AS3 definition of a service. 

**ADC Services** contains all the services tied to this User/Tenant. It will contain all the different services needed 
by the application defined in this tenant. 

.. note:: it is worth highlighting that in each repo, we leverage the dev branch. The idea is to explain how you can
    create a CI/CD pipeline for the dev branch and replicate the same process for the *master* or *prod* branch. for this 
    demo, we will use the dev branch. Make sure to select the right branch when browsing gitlab 

Gitlab setup - my-webapp-ci-cd-demo
-----------------------------------

Once you've selected the *dev* branch, you should see different folders in the **my-webapp-ci-cd-demo** repo. 

.. image:: ../../_static/class1/module1/001.png
    :align: center
    :scale: 50%
 
 
**Exercises in this Module**

- Lab 1.1 - trigger a pipeline

.. toctree::
   :maxdepth: 1
   :glob:

   lab*