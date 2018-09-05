# ARrange iOS

Ce projet contient un _proof of concept_ des fonctionnalités iOS ARKit dans le contexte du projet ARrange.

L'objectif de ce projet est de récupérer toutes les informations disponibles et nécessaires côté client (smartphone) afin de les transmettre au serveur. Le serveur tentera de détecter les différents objets et surfaces et de les renvoyer afin de les afficher sur le client.

Actuellement, l'application propose un bouton qui lorsqu'il est appuyé récupère l'image affichée sur l'écran (screenshot), l'image capturée par la caméra et divers propriétés. Le screenshot n'est pas traitable côté serveur puisqu'il contient tous les éléments d'UX et d'UI. Nous devons donc travailler avec l'image capturée par la caméra. Nous récupérons les nuages de points et les matrices détectés via l'ARFrame de ARKit. Dans cette phase de test, l'application tente de reproduire visuellement le nuage de points sur l'image capturée afin de pouvoir le comparé au screenshot et à celle reproduite côté serveur.

Note: Il a été testé dans un projet précédant qu'il est tout à fait possible d'envoyer (HTTP POST) l'image au serveur de manière invisible pour l'utilisateur. Pour cela il est par exemple possible d'utiliser la librairie [Alamofire](https://github.com/Alamofire/Alamofire). 