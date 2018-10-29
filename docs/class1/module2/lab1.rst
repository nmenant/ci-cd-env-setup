Deploy a new Application
------------------------

Here is the recommended worklow to do this demo. 

Open different tabs in your browser: 

* Open 2 *GitLab* tabs: one for the **my-webapp-ci-cd-demo** repo and the other one for the 
  **ADC-Services** repo. **don't forget to go to the DEV branch**. 
* Open 2 *Jenkins* tabs: one for the **my-webapp-ci-cd-demo-dev** project and the other one 
  for the **adc-services-dev** project 
* Open 1 tab on your BIG-IP to show its configuration (highlight that there is no *tenanta-dev* partition
* Open 1 tab on your minishift deployment (*login*: dev, *password*: dev). Go in the 

Make sure that: 

* the *DELETE* file exists in the **my-webapp-ci-cd-demo** repo. 
* Your BIG-IP configuration doesn't have a *tenanta-dev* partition
* You don't have any App deployed in your minishift system in the tenanta-dev project. 

In this demo, we use the *DELETE* file to leverage either the APP deployment, or its removal. 

If everything is up and running as expect, you'll only need to do the following to trigger the deployment 
of the app: 

* Delete the *DELETE* file from the **my-webapp-ci-cd-demo** repo. 
* if you use an editor instead of the GitLab UI, make sure to commit your changes to trigger the WebHook. 

Here is how to do it from the *GitLab* UI: 

* Open the tab showing your **my-webapp-ci-cd-demo** repo and click on the *DELETE* file. 

.. image:: ../../_static/class1/module1/img004.png
    :align: center
    :scale: 30%

* Click on the red *DELETE* button on the right

.. image:: ../../_static/class1/module1/img005.png
    :align: center
    :scale: 30%

* Confirm that you want to delete the file by clicking on the *Delete File* button.

.. image:: ../../_static/class1/module1/img006.png
    :align: center
    :scale: 30%

As soon as you'll do it from the GUI of *GitLab* it will be committed.