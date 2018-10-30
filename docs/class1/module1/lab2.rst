Review Jenkins setup
--------------------

the next DevOps tools we leverage in this environment is *Jenkins*. It is a *CI Server* that we will use 
to execute DevOps *pipeline*. 

Here is a good overview of Jenkins_ and how to work with *pipelines*.

.. _Jenkins: https://www.infoworld.com/article/3239666/devops/what-is-jenkins-the-ci-server-explained.html

Connect to your *Jenkins* Server. It should be http://<IP of your VM>:1180/

* Login: TenantA
* Password: Pa55w0rd

.. image:: ../../_static/class1/module1/img008.png
    :align: center
    :scale: 50%

On the main page, we can see two different items: 

* adc-services-dev
* my-webapp-ci-cd-demo-dev

Those 2 items are pipelines. Each of them will be *triggered* by the *WebHooks* we have seen during the *GitLab* 
review.  You can see those *WebHooks* by going back to the *GitLab* interface and go into *Settings* > 
*Integration* in each of the different repo **my-webapp-ci-cd-demo** and **ADC-Services** (Login: TenantA, 
Password: Pa55w0rd)

.. image:: ../../_static/class1/module1/img003.png
    :align: center
    :scale: 50%

|

.. image:: ../../_static/class1/module1/img007.png
    :align: center
    :scale: 50%

The my-webapp-ci-cd-demo-dev pipeline
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

On the *Jenkins* GUI, click on the pipeline called *my-webapp-ci-cd-demo-dev*

.. image:: ../../_static/class1/module1/img013.png
    :align: center
    :scale: 50%

You should see something like this : 

.. image:: ../../_static/class1/module1/img014.png
    :align: center
    :scale: 50%

If you have never triggered the pipeline, the build section may be empty: 

.. image:: ../../_static/class1/module1/img015.png
    :align: center
    :scale: 50%

A *build* is one execution of your *pipeline*. It will show: 

* the different steps of your pipeline (here we can see *build app*, *test app*, ...)
* if each step is successful or not. If a step fail, it will be red and the pipeline will stop immediately

if you click on a build number, you will be able to review in details this *pipeline* execution. It will 
help you review its execution and whether it has been executed successfully or not

.. image:: ../../_static/class1/module1/img016.png
    :align: center
    :scale: 50%

We can review a few options in the left menu : 

* *Build now*: This would trigger the execution of the *pipeline* even if *GitLab* didn't send a *WebHook*. 
  it's convenient when working on a pipeline for troubleshooting purposes
* *Configure*: Give you access to the setup of this *pipeline*. We will review it later
* *GitHub*: Link to send you to the related *Github*/*GitLab* repo. It's defined in the setup. 

We can click on *Configure* to review the setup of this *pipeline*. 

.. image:: ../../_static/class1/module1/img017.png
    :align: center
    :scale: 50%

|

.. image:: ../../_static/class1/module1/img018.png
    :align: center
    :scale: 50%

Let's review the different sections of our *pipeline*

Scroll down to the *Github* section: 

.. image:: ../../_static/class1/module1/img019.png
    :align: center
    :scale: 50%

Here we reference our related *GitLab* project. We specify the URL to it and how to authenticate on 
this repo (in case it's needed). We reference *GitLab local* which has been setup previously. You 
can check the authentication that has been setup here: *Jenkins Home page* > *Manage Jenkins* > 
*Configure System* and scroll down to the *GitLab* section

.. image:: ../../_static/class1/module1/img020.png
    :align: center
    :scale: 50%

In the *Build Triggers* section of your *pipeline*, you can see the following: 

.. image:: ../../_static/class1/module1/img021.png
    :align: center
    :scale: 50%

Here we explain when a new *build* of our *pipeline* should be triggered: We explain that if we receive 
a *WebHook* to this specific URL: *http://172.18.0.3:8080/project/my-webapp-ci-cd-demo-dev* , we will 
trigger a *build*

If you remember the *GitLab* setup, we specified for the **my-webapp-ci-cd-demo** repo a *WebHook* 
targetting this URL: 

.. image:: ../../_static/class1/module1/img003.png
    :align: center
    :scale: 50%
