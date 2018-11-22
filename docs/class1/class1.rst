***********************************
Class 1 - demo IaC with CI/CD Tools
***********************************

This class will teach you how to do Infrastructure as Code (IaC) with F5 solutions. 

In this class, we have setup different DevOps tools to do the demonstration: 

* Gitlab: It will host our applications and services definition
* Jenkins: it will be our CI Server
* Consul: it will be used to store *secrets* and infrastructure information like BIG-IP IP, ...
* Openshift: We will use Minishift to host our deployed applications 
* AS3: We will leverage the AS3 extension to be able to consume a declarative interface for 
  services instantiation. To know more about AS3, please visit AS3_. 

  .. _AS3: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/3/

  If you just want to do a CI/CD Demo with F5 *BIG-IP* and *AS3*, you may review module2 to see how 
  to do a demo. 
  If you want a deeper understanding of the setup, module1 will give you an overview of how everything 
  is setup to work together.


.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*