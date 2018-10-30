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

