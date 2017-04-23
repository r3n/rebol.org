rebol [
    Library: [
        level: 'intermediate
        platform: 'all
        type: tool 
        domain: 'files
        tested-under: windows XP SP2
        support: none
        license: none
        see-also: none
        ]

  	
	title: "XPDev"
        Date: 23-May-06
	File: %xpdev.r
	purpose: "XPDev is a program that helps XP devellopers to manage documentation"
	Rights: {Xavier Debecq/XPTeamer. Realesed under no licence but please send me feedback}
	version: [0.0.2 [24-mar-06]]
	level: 'beginner
	support: none (at this time/it s a work for my graduation)
]

I-O-problem: copy []
repository-url: copy []
; fonctions de creation
;creation d'un projet
create-project: func [
	"cree le projet"
] [
	I-O-problem: copy []
	object-project: make object! [
		names: ""
		users: copy []
		date: date!
		description: string!
		iterations: copy []
		stories-pool: copy []
	]
	either not attempt [
		delete-dir %/C/XPDev
		change-dir make-dir/deep %/C/XPDev/objects/object-project
		save %object-project.o object-project
		return true
	]
	[
		append I-O-problem "problem with the creation of the project"
		return false
	]
	[
		return true
	]
]
;creation et ajout d'un utilisateur
create-add-user: func [
	"cree des users et les attache au projet"
	name-new-user [string!] "nom du nouvel utilisateur"
	email-new-user [email!] "email du nouvel utilisateur"
] [
	I-O-problem: copy []
	either not attempt [
		;ici on cr�e l'user

		user: reduce [
			name-new-user
			reduce [
				email-new-user
			]
		]
		object-project: load-project
		append object-project/users user
		save-project object-project
		return true
	]
	[
		append I-O-problem "problem with the creation of the user"
		return false
	]
	[
		return true
	]
]
;creation et ajout d'une it�ration au projet
create-add-iteration: func [
	"cree des iterations et les rattache au projet"
	date-debut [date!] "date de d�but de l'it�ration"
	date-fin [date!] "date de fin de l'it�ration"
	description [string!] "description de l'it�ration"
	title [string!] "titre de l'it�ration"
]
[
	I-O-problem: copy []
	object-iteration: make object! [
		tit: string!
		desc: string!
		date-begining: date!
		date-end: date!
		state: string!
		stories-iteration: copy []
	]
	object-iteration/tit: title
	object-iteration/desc: description
	object-iteration/date-begining: date-debut
	object-iteration/date-end: date-fin
	object-iteration/state: "iddle"
	either not attempt
	[
		id: to-string get-time-stamp
		object-project: load-project
		append object-project/iterations id
		append object-project/iterations title
		save-project object-project
		make-dir/deep %/C/XPDev/objects/object-iterations
		test: to-file join id ".o"
		save-iteration test object-iteration
		return true
	]
	[
		append I-O-problem "problem with the creation of the iteration"
		return false
	]
	[
		return true
	]
]

;creation et ajout d'une task a la story

create-add-task: func [
	"cr�e une task et les rattache au projet"
	id-story [string!] "identifiant de la story a laquelle la task se rattache"
	my-date-task [date!] "date de d�but de la task"
	my-title-task [string!] "titre de la task"
	my-story-task [string!] "story qui contient la task"
	my-in-task [string!] "variables d'entr�es de la task"
	my-out-task [string!] "variables de retour de la task"
	my-responsabilities-task [string!] "buts de la taches"
	my-collaborations-task [string!] "collaborations de la taches"
] [
	I-O-problem: copy []
	object-task: make object! [
		story-task: copy []
		date-task: my-date-task
		title-task: my-title-task
		in-task: my-in-task
		out-task: my-out-task
		responsabilities-task: my-responsabilities-task
		collaborations-task: my-collaborations-task
		task-tests: copy []
		log: copy []
		task-state: "iddle"
	]

	either not attempt
	[

		id: to-string get-time-stamp
		object-story: load-story id-story
		append object-story/tasks-pool id
		append object-story/tasks-pool my-title-task
		append object-task/story-task id-story
		save-story to-file join id-story ".o" object-story
		make-dir/deep %/C/XPDev/objects/object-tasks/
		save-task to-file join id ".o" object-task
		return true
	]
	[
		append I-O-problem join "problem with the creation of the task"
		return false
	]
	[
		return true
	]
]


;creation et ajout d'une story au projet
create-add-story: func [
	"cr�e une story et les rattache au projet"
	my-date-story [date!] "date de d�but de la story"
	my-description-story [string!] "description de la story"
	my-title-story [string!] "titre de la story"
	my-estimate-story [integer!] "estimation en points de la story"
	my-risk-story [integer!] "estimation du programmeur du risque technique"
	my-user-prior-story [integer!] "priorit� de l'utilisateur"
	my-tech-prior-story [integer!] "priorit� technique"
] [

	I-O-problem: copy []
	object-story: make object! [
		my-story-iterations: copy []
		date-story: my-date-story
		description-story: my-description-story
		title-story: my-title-story
		estimate-story: my-estimate-story
		risk-story: my-risk-story
		user-prior-story: my-user-prior-story
		tech-prior-story: my-tech-prior-story
		tasks-pool: copy []
		my-story-state: "iddle"

	]

	either not attempt
	[

		id: to-string get-time-stamp
		object-project: load-project
		append object-project/stories-pool id
		append object-project/stories-pool my-title-story
		save-project object-project
		make-dir/deep %/C/XPDev/objects/object-stories
		save-story to-file join id ".o" object-story
		return true
	]
	[
		append I-O-problem join "problem with the creation of the story"
		return false
	]
	[
		return true
	]
]

;creation et addition d'un test

create-add-test: func ["cr�e une test et les rattache au projet"
	;id-story [string!] "identifiant de la story a laquelle le test se rattache"
	id-task [string!] "identifiant de la task a laquelle le test se rattache"
	my-date-test [date!] "date de cr�ation du test"
	my-description-test [string!] "description du test"
	my-pre-cond-test [string!] "pr�condition du test"
	my-post-cond-test [string!] "postcondition du test"
	my-in-test [string!] "Entr�es du test"
	my-out-test [string!] "Sorties du test"
] [
	I-O-problem: copy []
	object-test: make object! [
		;story-test: id-story
		task-test: id-task
		date-test: my-date-test
		description-test: my-description-test
		in-test: my-in-test
		out-test: my-out-test
		test-state: "iddle"
		pre-cond-test: my-pre-cond-test
		post-cond-test: my-post-cond-test

	]
	either not attempt
	[
		id: to-string get-time-stamp
		object-task: load-task id-task
		append object-task/task-tests id
		save-task to-file join id-task ".o" object-task
		make-dir/deep %/C/XPDev/objects/object-tests
		save-test to-file join id ".o" object-test
		return true
	]
	[
		append I-O-problem join "problem with the creation of the test"
		return false
	]
	[
		return true
	]
]

;fonctions d'acces au disque
;fonctions load

;chargement de l'url du repository

load-url-repository: func [
	"charge l'url dans la s�rie url-repository pr�vue a cet effet"
] [
	either not attempt
	[
		either not attempt [
			url-rep: load %//XPDev/settings/url-rep.s
		]
		[
			change-dir make-dir %//XPDev/settings/
			save %url-rep.s "none"
			return false
		]
		[
			append repository-url url-rep
			return true
		]
	]
	[
		append I-O-problem "problem with the repository ... you should check it"
		return false
	]
	[return true]
]

; fonction de chargement de la task

load-test: func [
	"retourne l'objet test dont on a pass� l'identifiant en param�tre"
	id-test [string!] "identifiant du test"
] [
	I-O-problem: copy []
	either not attempt [
		change-dir %/C/xpdev/objects/object-tests/
		object-test: do load to-file join id-test ".o"
	]
	[
		append I-O-problem join "problem with the loading of the test" id-test
		return false
	]
	[
		return object-test
	]
]

load-task: func [
	"retourne l'objet task dont on a pass� l'identifiant en param�tre"
	id-task [string!] "identifiant de la task"
] [
	I-O-problem: copy []
	either not attempt [
		change-dir %/C/xpdev/objects/object-tasks/
		object-task: do load to-file join id-task ".o"
	]
	[
		append I-O-problem join "problem with the loading of the task " id-task
		return false
	]
	[
		return object-task
	]
]

; fonction de chargement de la story
load-story: func [
	"retourne l'objet story dont on a pass� l'identifiant en param�tre"
	id-story [string!] "identifiant de la story"
] [
	I-O-problem: copy []
	either not attempt [
		change-dir %/C/xpdev/objects/object-stories/
		object-story: do load to-file join id-story ".o"
	]
	[
		append I-O-problem join "problem with the loading of iteration " id-story
		return false
	]
	[
		return object-story
	]
]

;fonction de chargement de l'it�ration

load-iteration: func [
	"va rechercher une it�ration sur le disque et l'instancie"
	id-iteration [string!] "identifiant et nom sur le disque de l'iteration"
] [
	I-O-problem: copy []
	either not attempt [
		change-dir %/C/xpdev/objects/object-iterations/
		object-iteration: do load to-file join id-iteration ".o"
	]
	[
		append I-O-problem join "problem with the loading of iteration " id-iteration
		return false
	]
	[
		return object-iteration
	]
]

;fonction de chargement du projet
load-project: func [
	"charge le projet"
] [
	I-O-problem: copy []
	either not attempt [
		object-project: do load %/C/xpdev/objects/object-project/object-project.o
	]
	[
		return object-project: create-project
	]
	[
		return object-project
	]
]

;fonctions save

;sauvegarde de l'url

save-url-repository: func [
	"sauvegarde l'url du repository sur le dd du client"
	url-rep [url!] "url du repository"
] [
	either not attempt [
		save %//XPDev/settings/url-rep.s url-rep
		return true
	]
	[
		append I-O-problem "problem with the repository"
		return false
	]
	[
		return true
	]
]

;fonction de sauvegarde du projet
save-project: func [
	"sauve le projet"
	object-project [object!] "projet avec toutes les informations"
]
[
	I-O-problem: copy []
	either not attempt [

		either (empty? repository-url) [
			change-dir %/C/XPDev/objects/object-project/
			save %object-project.o object-project
		]
		[
			where: to-url join repository-url/1 /C /XPDev /objects /object-project /object-project.o
			save where object-project
		]
		return true

	]
	[
		append I-O-problem "probleme a l'enregistrement du projet"
		return false
	]
	[
		return true
	]
]

;fonction de sauvegarde de l'it�ration
save-iteration: func [
	"sauve une iteration"
	name [file!] "nom de l'it�ration"
	iteration [object!] "it�ration sous forme d'objet avec tout ses renseignement"
] [
	I-O-problem: copy []
	either not attempt [
		either (empty? repository-url) [
			change-dir %/C/XPDev/objects/object-iterations
			save name iteration
		]
		[
			where: to-url join repository-url/1 [/C /XPDev /objects /object-iterations / name]
			save where object-project
		]
		return true
	]
	[
		append I-O-problem "problem with the saving of the iteration"
		return false
	]
	[
		return true
	]
]
;fonction de sauvegarde de la story
save-story: func [
	"sauve une story sur le disque"
	name [file!] "nom de la story sur le disque"
	story [object!] "story avec tous ses attributs"
] [
	I-O-problem: copy []
	either not attempt [
		either (empty? repository-url) [
			change-dir %/C/XPDev/objects/object-stories
			save name story
		]
		[
			where: to-url join repository-url/1 [/C /XPDev /objects /object-stories / name]
			save where story
		]
		return true
	]
	[
		append I-O-problem join "problem with the saving of the story" name
		return false
	]
	[
		return true
	]
]
;task 
save-task: func [
	"sauve une task sur le disque"
	name [file!] "nom de la story sur le disque"
	task [object!] "task a sauver"

] [
	I-O-problem: copy []
	either not attempt [
		either (empty? repository-url) [
			change-dir %/C/XPDev/objects/object-tasks
			save name task
		]
		[
			where: to-url join repository-url/1 [/C /XPDev /objects /object-tasks / name]
			save where task
		]
		return true
	]
	[
		append I-O-problem join "problem with the saving of the task" name
		return false
	]
	[
		return true
	]
]

;sauve le test
save-test: func [
	"sauve une test sur le disque"
	name [file!] "nom de la test sur le disque"
	test [object!] "test avec tous ses attributs"
] [
	I-O-problem: copy []
	either not attempt [
		either (empty? repository-url) [
			change-dir %/C/XPDev/objects/object-tests
			save name test
		]
		[
			where: to-url join repository-url/1 [/C /XPDev /objects /object-tasks / name]
			save where task
		]
		return true
	]
	[
		append I-O-problem join "problem with the saving of the test" name
		return false
	]
	[
		return true
	]
]

;fonctions qui vont modifier un �l�ment
; projet
launch-project: func [
	"lance le projet"
	project-name [string!] "nom du projet"
	project-description [string!] "texte de la description du projet"
]
[
	I-O-problem: copy []
	either not attempt [
		object-project: load-project
		object-project/date: now/date
		object-project/names: project-name
		object-project/description: project-description
		return true
	]
	[
		append I-O-problem "problem with the launching of the project"
		return false
	]
	[
		either (save-project object-project)
		[
			return true
		]
		[
			append I-O-problem "problem with the launching of the project"
			return false
		]
	]
]
;modifie le projet en cours

modify-project-m: func [
	"modifie le projet en cours"
	project-name [string!] "nom du projet"
	project-description [string!] "texte de la description du projet"
	project-date [date!] "date de d�but du projet"
] [
	I-O-problem: copy []
	either not attempt [
		object-project: load-project
		object-project/date: project-date
		object-project/names: project-name
		object-project/description: project-description
		return true
	]
	[
		append I-O-problem "problem with the modification of the project"
		return false
	]
	[
		either (save-project object-project)
		[
			return true
		]
		[
			append I-O-problem "problem with the modification of the project"
			return false
		]
	]
]
;modifie une it�ration

modify-iteration: func [
	"modifie des iterations et les rattache au projet"
	date-debut [date!] "date de d�but de l'it�ration"
	date-fin [date!] "date de fin de l'it�ration"
	description [string!] "description de l'it�ration"
	title [string!] "titre de l'it�ration"
	id-iteration [string!] "identifiant de l'it�ration"
]
[
	I-O-problem: copy []
	either not attempt
	[
		object-iteration: load-iteration id-iteration
		object-iteration/tit: title
		object-iteration/desc: description
		object-iteration/date-begining: date-debut
		object-iteration/date-end: date-fin
		object-project: load-project
		object-project/iterations
		;changer un �l�ment dans une s�rie a une position donn�e
		l1: length? object-project/iterations
		l2: length? find object-project/iterations id-iteration
		pos: l1 - l2 + 2
		poke object-project/iterations :pos title
		save-project object-project
		save-iteration to-file join id-iteration ".o" object-iteration
		return true
	]
	[
		append I-O-problem "problem with the modification of the iteration"
		return false
	]
	[
		return true
	]
]

;story

modify-story: func [
	"modifie une story"
	my-date-story [string!]
	my-description-story [string!] ""
	my-title-story [string!] "titre de la story"
	my-estimate-story [string!] "difficult� estim�e de la story"
	my-risk-story [string!] "risque technique de la story"
	my-user-prior-story [string!] "priorit� utilisateur"
	my-tech-prior-story [string!] "priorit� technique de la story"
	id-story [string!] "identifiant de la story"
] [
	I-O-problem: copy []
	either not attempt
	[
		my-date-story: to-date my-date-story
		my-estimate-story: to-integer my-estimate-story
		my-risk-story: to-integer my-risk-story
		my-user-prior-story: to-integer my-user-prior-story
		my-tech-prior-story: to-integer my-tech-prior-story
		object-story: load-story id-story
		object-story/date-story: my-date-story
		object-story/description-story: my-description-story
		object-story/title-story: my-title-story
		object-story/estimate-story: my-estimate-story
		object-story/risk-story: my-risk-story
		object-story/user-prior-story: my-user-prior-story
		object-story/tech-prior-story: my-tech-prior-story
		object-project: load-project
		;changer un �l�ment dans une s�rie a une position donn�e
		l1: length? object-project/stories-pool
		l2: length? find object-project/stories-pool id-story
		pos: l1 - l2 + 2
		poke object-project/stories-pool :pos my-title-story
		save-project object-project
		save-story to-file join id-story ".o" object-story
		return true
	]
	[

		return true
	]
	[
		append I-O-problem "problem with the modification of the story"
		return false
	]
	[
		return true
	]
]

;fonctions qui vont chercher des donn�es dans l'environement

; get-time-stamp

get-time-stamp: func [
	"cr�e un time stamp"
]
[
	time-stamp: form now
	foreach char ["-" "/" ":" "+"] [time-stamp: replace/all time-stamp char ""]
	time-stamp
]

;fonctions qui effacent physiquement des objets
erase-iteration: func [
	"efface physiquement l'it�ration"
	id-iteration [string!]
] [
	change-dir %/C/xpdev/objects/object-iterations/
	delete to-file join %/C/xpdev/objects/object-iterations/ [id-iteration ".o"]
]

erase-story: func [
	"efface physiquement la story"
	id-story [string!]
] [
	change-dir %/C/xpdev/objects/object-stories/
	delete to-file join %/C/xpdev/objects/object-stories/ [id-story ".o"]
]
erase-task: func [
	"efface physiquement la task"
	id-task [string!]
] [
	change-dir %/C/xpdev/objects/object-tasks/
	delete to-file join %/C/xpdev/objects/object-tasks/ [id-task ".o"]
]

erase-test: func [
	"efface physiquement le test"
	id-test [string!] "identifiant du test"
] [
	change-dir %/C/xpdev/objects/object-tests/
	delete to-file join %/C/xpdev/objects/object-tests/ [id-test ".o"]
]

load-url-repository

wrong-fields: copy []
user-logged: copy []
companion: copy []
working-task: copy []
;fonctions verifiant l'existence d'une donn�e

;existence de l'utilisateur

check-existence-user: func [
	"verfie l'existence d'un user dans le projet en cours"
	name [string!] "nom du suppos� user"
] [
	object-project: load-project
	either not attempt
	[
		find object-project/users name
	]
	[
		return false
	]
	[
		return true
	]
]

;existence du nom du projet

check-name-project: func [
	"v�rifie l'existence du nom du projet en cours"
] [
	object-project: load-project
	either
	(
		empty? object-project/names
	)
	[
		return false
	]
	[
		return true
	]
]

;validations de groupes de donnees

;validation de l'url

validate-repository: func [
	"v�rifie si l'url du repository est valide ou non"
	url-rep [string!] "url du repository"
] [
	url-block: to-block url-rep
	test1: empty? url-rep
	test2: url? url-block/1

	either (test1 or test2)
	[
		either (empty? url-rep)
		[
			url-rep: to-url url-rep
			save-url-repository url-rep
			return true
		]
		[
			url-rep: to-url url-rep
			save-url-repository url-rep
			return true
		]
	]
	[
		append wrong-fields "wrong url"
		return false
	]
]

;validation d'un test

validate-modified-state-test: func [
	"valide la modification d'un etat du test"
	id-test [string!] "identifiant du test"
] [
	either not attempt [
		object-test: load-test id-test
		either (object-test/test-state = "iddle")
		[object-test/test-state: "done"] ;<<<
		[object-test/test-state: "iddle"] ;<<<
		save-test to-file join id-test ".o" object-test
		return true
	]
	[return false]
	[return true]
]

validate-test: func [
	"verifie le validit� d' un test"
	;id-story [string!] "identifiant de la story a laquelle le test se rattache"
	id-task [string!] "identifiant de la task a laquelle le test se rattache"
	my-date-test [date!] "date de creation du test"
	my-description-test [string!] "description du test"
	my-pre-cond-test [string!] "pr�condition du test"
	my-post-cond-test [string!] "postcondition du test"
	my-in-test [string!] "Entr�es du test"
	my-out-test [string!] "Sorties du test"
] [
	wrong-fields: copy []
	either not attempt
	[
		if (not validate-date-test my-date-test id-task) [append wrong-fields "date test not correct"]
		if (not validate-description-test my-description-test) [append wrong-fields "wrong description"]
		if (not validate-my-pre-cond-test my-pre-cond-test) [append wrong-fields "wrong pre-condition"]
		if (not validate-my-post-cond-test my-post-cond-test) [append wrong-fields "wrong post-condition"]
		if (not validate-my-in-test my-in-test) [append wrong-fields "wrong in"]
		if (not validate-my-out-test my-out-test) [append wrong-fields "wrong out"]
		either not (empty? wrong-fields)
		[return false]
		[return true] ;
	]
	[


		return false
	]
	[
		either (
			create-add-test id-task my-date-test my-description-test my-pre-cond-test my-post-cond-test my-in-test my-out-test ;<<<
		)

		[return true]
		[

			return false]
	]
]

;validation d'une task

validate-task: func [
	"verifie la validit� d' une task"
	id-story [string!] "identifiant de la story a laquelle la task se rattache"
	my-date-task [date!] "date de d�but de la task"
	my-title-task [string!] "titre de la task"
	my-in-task [string!] "variables d'entr�es de la task"
	my-out-task [string!] "variables de retour de la task"
	my-responsabilities-task [string!] "buts de la taches"
	my-collaborations-task [string!] "collaborations de la taches"
]
[
	wrong-fields: copy []
	object-story: load-story id-story
	my-story-task: object-story/title-story
	either not attempt
	[
		if (not validate-my-date-task my-date-task id-story) [append wrong-fields "wrong date"]
		if (not validate-my-title-task my-title-task) [append wrong-fields "wrong title"]
		if (not validate-my-in-task my-in-task) [append wrong-fields "wrong in"]
		if (not validate-my-out-task my-out-task) [append wrong-fields "wrong out"]
		if (not validate-my-responsabilities-task my-responsabilities-task) [append wrong-fields "wrong responsabilities"]
		if (not validate-my-collaborations-task my-collaborations-task) [append wrong-fields "wrong collaborations"]
		either (empty? wrong-fields)
		[return true]
		[return false]
	]
	[
		return false
	]
	[
		either (
			create-add-task
			id-story
			my-date-task
			my-title-task
			my-story-task
			my-in-task
			my-out-task
			my-responsabilities-task
			my-collaborations-task
		)

		[return true]
		[return false]
	]
]
;validation d'une story
validate-story: func [
	"valide les donn�es d'une it�ration avant la cr�ation"
	my-date-story [string!] "date de d�but de la story"
	my-description-story [string!] "description de la story"
	my-title-story [string!] "titre de la story"
	my-estimate-story [string!] "estimation en points de la story"
	my-risk-story [string!] "estimation du programmeur du risque technique"
	my-user-prior-story [string!] "priorit� de l'utilisateur"
	my-tech-prior-story [string!] "priorit� technique"
] [
	wrong-fields: copy []
	either not attempt
	[
		if (not validate-description-story my-description-story) [append wrong-fields "wrong description"]
		if (not validate-title-story my-title-story) [append wrong-fields "wrong title story"]
		if (not validate-estimate-story my-estimate-story) [append wrong-fields "wrong estimation"]
		if (not validate-risk-story my-risk-story) [append wrong-fields "wrong risk"]
		if (not validate-user-prior-story my-user-prior-story) [append wrong-fields "wrong user priority"]
		if (not validate-tech-prior-story my-tech-prior-story) [append wrong-fields "wrong technical risk"]
		either (empty? wrong-fields)
		[return true]
		[return false]
	]
	[
		return false
	]
	[
		either (create-add-story to-date my-date-story my-description-story my-title-story to-integer my-estimate-story to-integer my-risk-story to-integer my-user-prior-story to-integer my-tech-prior-story)
		[
			return true
		]
		[
			return false
		]
	]
]

;validation d'une story modifi�e

validate-modified-story: func [
	"verifie la validit� d' une story modifi�e"
	my-date-story [string!] "date de d�but de la story"
	my-description-story [string!] "description de la story"
	my-title-story [string!] "titre de la story"
	my-estimate-story [string!] "estimation en points de la story"
	my-risk-story [string!] "estimation du programmeur du risque technique"
	my-user-prior-story [string!] "priorit� de l'utilisateur"
	my-tech-prior-story [string!] "priorit� technique"
	id-story [string!] "identifiant de la story"
]
[

	wrong-fields: copy []
	either not attempt
	[
		if (not validate-date-story my-date-story) [append wrong-fields "wrong date"]
		if (not validate-description-story my-description-story) [append wrong-fields "wrong description"]
		if (not validate-title-story my-title-story) [append wrong-fields "wrong title story"]
		if (not validate-estimate-story my-estimate-story) [append wrong-fields "wrong estimation"]
		if (not validate-risk-story my-risk-story) [append wrong-fields "wrong risk"]
		if (not validate-user-prior-story my-user-prior-story) [append wrong-fields "wrong user priority"]
		if (not validate-tech-prior-story my-tech-prior-story) [append wrong-fields "wrong technical risk"]
		either (empty? wrong-fields)
		[return true]
		[return false]
	]
	[
		return false
	]
	[
		either (modify-story my-date-story my-description-story my-title-story my-estimate-story my-risk-story my-user-prior-story my-tech-prior-story id-story)
		[return true]
		[return false]
	]
]

; validation d'une iteration
validate-iteration: func [
	"verifie la validit� d' une iteration"
	date-debut [string!] "date de d�but de l'it�ration"
	date-fin [string!] "date de fin de l'it�ration"
	title [string!] "titre de l'it�ration"
	description [string!] "description de l'it�ration"
]
[
	wrong-fields: copy []
	either not attempt
	[
		if (not validate-date-debut-it date-debut) [append wrong-fields "wrong debut date"]
		if (not validate-date-fin-it date-debut date-fin) [append wrong-fields "wrong end date"]
		if (not validate-title-it title) [append wrong-fields "wrong title"]
		if (not validate-description-it description) [append wrong-fields "wrong description"]
		either (empty? wrong-fields)
		[return true]
		[return false]
	]
	[
		return false
	]
	[
		either (create-add-iteration to-date date-debut to-date date-fin title description)
		[return true]
		[return false]
	]
]

; validation d'une it�ration modifi�e

validate-modified-iteration: func [
	"verifie la validit� d' une iteration modifi�e"
	date-debut [string!] "date de d�but de l'it�ration"
	date-fin [string!] "date de fin de l'it�ration"
	title [string!] "titre de l'it�ration"
	description [string!] "description de l'it�ration"
	id-iteration [string!] "identifiant de l'it�ration"
]
[
	wrong-fields: copy []

	either not attempt
	[
		if (not validate-date-debut-it date-debut) [append wrong-fields "wrong debut date"]
		if (not validate-date-fin-it date-debut date-fin) [append wrong-fields "wrong end date"]
		if (not validate-title-it title) [append wrong-fields "wrong title"]
		if (not validate-description-it description) [append wrong-fields "wrong description"]
		either (empty? wrong-fields)
		[return true]
		[return false]
	]
	[
		return false
	]
	[
		either (modify-iteration to-date date-debut to-date date-fin title description id-iteration)
		[return true]
		[return false]
	]
]
;validation d'un user

validate-user: func [
	"verifie la validit� d'un user"
	user-name [string!] "nom du user"
	user-email [string!] "email du user"
]
[
	wrong-fields: copy []
	I-O-problem: copy []
	either not attempt
	[
		if (not validate-user-name user-name) [append wrong-fields "wrong user name"]
		if (not validate-user-email user-email) [append wrong-fields "wrong user email"]
		either (empty? wrong-fields)
		[return true]
		[return false]
	]
	[
		return false
	]
	[
		either (create-add-user user-name to-email user-email)
		[return true]
		[return false]
	]
]
;validation d'un projet

validate-project: func [
	"v�rifie la validit� du projet"
	project-name [string!] "nom du projet"
	project-description [string!] "texte de la description du projet"
] [
	wrong-fields: copy []

	either not attempt
	[
		if (not validate-name-proj project-name) [append wrong-fields "wrong project name"]
		if (not validate-desc-proj project-description) [append wrong-fields "wrong description"]
		either (empty? wrong-fields)
		[return true]
		[return false]
	]
	[
		return false
	]
	[
		either (launch-project project-name project-description)
		[return true]
		[return false]
	]
]
;validation d'un projet modif�
validate-project-modified: func [
	"valide le projet apres modification"
	project-name [string!] "nom du projet"
	project-description [string!] "texte de la description du projet"
	project-date [date!] "date de d�but du projet"
] [
	wrong-fields: copy []
	either not attempt
	[
		if (not validate-name-proj project-name) [append wrong-fields "wrong project name"]
		if (not validate-desc-proj project-description) [append wrong-fields "wrong description"]
		either (empty? wrong-fields)
		[return true]
		[return false]
	]
	[
		return false
	]
	[
		either (modify-project-m project-name project-description project-date)
		[

			return true
		]
		[

			return false
		]
	]
]

;validations de champs de formulaires

;validation du test

validate-date-test: func [
	"valide la date d'un test"
	my-date-task [date!] "date du test"
	id-task [string!] "identifiant de la task"
] [

	either not attempt
	[

		object-task: load-task id-task
		return [object-task/my-date-task]
	]
	[
		return false
	]
	[
		return true
	]
]

validate-description-test: func [
	"valide la description d'une test"
	my-description-test [string!] "description de la test"
] [
	either (not empty? my-description-test)
	[
		return true
	]
	[
		return false
	]
]

validate-my-pre-cond-test: func [
	"valide la my-pre-cond d'une test"
	my-pre-cond-test [string!] "pre-condition de la test"
] [
	either (not empty? my-pre-cond-test)
	[
		return true
	]
	[
		return false
	]
]

validate-my-post-cond-test: func [
	"valide la my-post-cond d'une test"
	my-post-cond-test [string!] "post-condition de la test"
] [
	either (not empty? my-post-cond-test)
	[
		return true
	]
	[
		return false
	]
]

validate-my-in-test: func [
	"valide la my-in d'une test"
	my-in-test [string!] "inition de la test"
] [
	either (not empty? my-in-test)
	[
		return true
	]
	[
		return false
	]
]

validate-my-out-test: func [
	"valide la sortie d'un test"
	my-out-test [string!] "entree du test"
] [
	either (not empty? my-out-test)
	[
		return true
	]
	[
		return false
	]
]


;validation de la task
validate-my-date-task: func [
	"valide la date d'une task"
	my-date-task [date!] "date de la task"
	id-story [string!] "identifiant de la story"
] [
	either not attempt
	[
		object-story: load-story id-story
		return [object-story/my-story-date >= my-date-task]
	]
	[
		return false
	]
	[
		return true
	]
]


validate-my-title-task: func [
	"valide le titre de la story"
	my-title-task [string!]
] [
	either (not empty? my-title-task)
	[
		return true
	]
	[
		return false
	]
]

validate-my-in-task: func [
	"valide les entr�es de la task"
	my-in-task [string!]
] [
	either (not empty? my-in-task)
	[
		return true
	]
	[
		return false
	]
]

validate-my-out-task: func [
	"valide les entr�es de la task"
	my-out-task [string!]
] [
	either (not empty? my-out-task)
	[
		return true
	]
	[
		return false
	]
]

validate-my-responsabilities-task: func [
	"valide les entr�es de la task"
	my-responsabilities-task [string!]
] [
	either (not empty? my-responsabilities-task)
	[
		return true
	]
	[
		return false
	]
]

validate-my-collaborations-task: func [
	"valide les entr�es de la task"
	my-collaborations-task [string!]
] [
	either (not empty? my-collaborations-task)
	[
		return true
	]
	[
		return false
	]
]
;validation du nom du binome
validate-companion: func [
	"verifie la validit� d'un binome"
	companion-name [string!] "nom du binome"
] [
	object-project: load-project
	either not attempt
	[
		either (empty? companion-name)
		[
			return true
		]
		[
			either (find object-project/users companion-name)
			[
				return true
			]
			[
				return false
			]
		]
	]
	[
		return false
	]
	[
		return true
	]
]
;validation du nom de login
validate-user-name: func [
	"verifie la validit� du nom du user"
	user-name [string!]
]
[
	object-project: load-project
	either not attempt
	[
		either (empty? user-name)
		[
			return false
		]
		[
			either (find object-project/users user-name)
			[
				return false
			]
			[
				return true
			]
		]
	]
	[
		return false
	]
	[
		return true
	]
]
validate-user-email: func [
	"v�rifie la validit� du email du user"
	email-user [string!]
]
[
	either not attempt
	[
		test: email? first to-block email-user
	]
	[
		return false
	]
	[
		return true
	]
]
;validation du formulaire de creation de l'iteration
validate-date-debut-it: func [
	"v�rifie la validit� de la date de d�but de l'it�ration"
	date-debut [string!] "date de d�but de l'it�ration"
]
[
	either not attempt [date: to-date date-debut]
	[
		return false
	]
	[
		return true
	]
]
validate-date-fin-it: func [
	"validation de la date de fin de l'it�ration"
	date-debut [string!] "date de d�but de l'it�ration"
	date-fin [string!] "date de fin de l'it�ration"
]
[
	either not attempt [
		date-debut: to-date date-debut
		date-fin: to-date date-fin
	]
	[
		return false
	]
	[
		either (positive? res: date-fin - date-debut)
		[return true]
		[return false]
	]
]

validate-description-it: func [
	"v�rifie la validit� de la description de l'iteration"
	description [string!] "description de l'it�ration"
]
[
	either (not empty? description)
	[
		return true
	]
	[
		return false
	]
]

validate-title-it: func [
	"v�rifie la validit� du titre de l'iteration"
	title [string!] "titre de l'it�ration"
]
[
	either (not empty? title)
	[
		return true
	]
	[
		return false
	]
]
;validation formulaire de creation du projet
validate-name-proj: func [
	"verifie la validit� du nom du projet"
	project-name [string!] "nom du projet"
] [
	either (empty? project-name)
	[return false]
	[return true]
]

validate-desc-proj: func [
	"verifie la validit� de la description du projet"
	project-desc [string!] "description du projet"
] [
	either (empty? project-desc)
	[return false]
	[return true]
]
;validation du formulaire de story

; description de la story
validate-description-story: func [
	"valide la description d'une story"
	my-description-story [string!] "description de la story"
] [
	either (not empty? my-description-story)
	[
		return true
	]
	[
		return false
	]
]

;titre de la story

validate-title-story: func [
	"valide le titre d'une story"
	my-title-story [string!] "titre de la story"
] [
	either (not empty? my-title-story)
	[
		return true
	]
	[
		return false
	]
]

;estimation de la story

validate-estimate-story: func [
	"valide l'estimation de la story"
	my-estimate-story [string!] "l'estimation de la story"
] [
	either (not to-logic attempt [to-integer my-estimate-story])
	[
		return false
	]
	[
		return true
	]

]
;risque de la story

validate-risk-story: func [
	"valide le risque technique de la story"
	my-risk-story [string!] "le risque de la story"
] [
	either (not to-logic attempt [to-integer my-risk-story])
	[
		return false
	]
	[
		return true
	]
]

;priorit� utilisateur

validate-user-prior-story: func [
	"valide la priorit� utilisateur de la story"
	my-user-prior-story [string!] "la priorit� utilisateur de la story"
] [
	either (not to-logic attempt [to-integer my-user-prior-story])
	[
		return false
	]
	[
		return true
	]
]

;priorit� technique
validate-tech-prior-story: func [
	"valide la priorit� technique de la story"
	my-tech-prior-story [string!] "la priorit� technique de la story"
] [
	either (not to-logic attempt [to-integer my-tech-prior-story])
	[
		return false
	]
	[
		return true
	]
]


;date de la story

validate-date-story: func [
	"valide la date de la story"
	my-date-story [string!] "date de la story"
] [
	either (not to-logic attempt [to-date my-date-story])
	[
		return false
	]
	[
		return true
	]

]


;fonction r�cup�rant une donn�e et la renvoyant vers la vue (get)

get-name-user: func [
	"retourne le nom du user"
] [
	return first user-logged
]

;donn�e de user
get-email-user: func [
	"fonction retournant le mail du user"
	name-user [string!] "nom du user"
]
[
	object-project: load-project
	either (email? info: first pick find object-project/users name-user 2)
	[
		info: to-string info
	]
	[
		info: ""
	]
	return info
]
;donn�es de project
;1st story
get-first-story: func [
	"retourne l'identifiant de la premi�re it�ration"
] [
	either not attempt
	[
		object-project: load-project

	]
	[
		foreach el I-O-problem [alert el]
		return ""
	]
	[
		return to-string test: object-project/stories-pool/1
	]
]

;1st iteration    
get-first-iteration: func [
	"retourne l'identifiant de la premi�re it�ration"
] [
	either not attempt
	[
		object-project: load-project

	]
	[
		foreach el I-O-problem [alert el]
		return ""
	]
	[
		return to-string test: object-project/iterations/1

	]
]
;nom
get-project-name: func [
	"retourne le nom du projet"
] [
	object-project: load-project
	return object-project/names
]
;date de cr�ation
get-project-date: func ["retourne la date de cr�ation du projet"] [
	object-project: load-project
	return to-string object-project/date
]
;description
get-project-description: func ["retourne la description du projet"] [
	object-project: load-project
	return object-project/description
]

;calcul de l'�tat du projet
get-state-project: func [
	"calcule l'�tat du projet"

] [

	either not attempt
	[
		object-project: load-project
		if (object-project = false) [return false]
		undone-i: 0
		done-i: 0
		iteration-serie: object-project/iterations
		forskip iteration-serie 2
		[
			object-iteration: load-iteration iteration-serie/1
			either (object-iteration/state = "done")
			[done-i: done-i + 1]
			[undone-i: undone-i + 1]
		]
		state: join 100 * (done-i / (undone-i + done-i)) " %"
		return true
	]
	[
		return "0 %"
	]
	[
		return state
	]
]

;etat en num�rique

get-state-project-numeric: func [
	"calcule l'�tat d'une it�ration dont on passe l'identifiant en param�tre"

] [

	either not attempt
	[
		object-project: load-project
		if (object-project = false) [return false]
		undone-i: 0
		done-i: 0
		iteration-serie: object-project/iterations
		forskip iteration-serie 2
		[
			object-iteration: load-iteration iteration-serie/1
			either (object-iteration/state = "done")
			[done-i: done-i + 1]
			[undone-i: undone-i + 1]
		]
		state: (done-i / (undone-i + done-i))
		return true
	]
	[
		return 0
	]
	[
		return state
	]
]


;donn�es d'iteration

get-iteration-name: func [
	"retourne le nom de l'it�ration dont l'identifiant a �t� pass� en param�tre ou une chaine vide si �chec"
	id-iteration [string!] "identifiant de l'it�ration"
] [
	either not attempt [
		object-iteration: load-iteration id-iteration
		either (object-iteration = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return object-iteration/tit
	]
]
get-iteration-description: func [
	"recherche la description d'une it�ration ou une chaine vide si l'id est invalide"
	id-iteration [string!] "identifiant de l'it�ration"
]
[
	either not attempt
	[
		object-iteration: load-iteration id-iteration
		either (object-iteration = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return object-iteration/desc
	]
]
get-iteration-end: func [
	"retourne la date de fin de l'it�ration dont l'identifiant a �t� pass� en param�tre ou une chaine vide si �chec"
	id-iteration [string!] "identifiant de l'it�ration"
] [
	either not attempt [
		object-iteration: load-iteration id-iteration
		either (object-iteration = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return object-iteration/date-end
	]
]
get-iteration-begining: func [
	"retourne la date de d�but de l'it�ration dont l'identifiant a �t� pass� en param�tre ou une chaine vide si �chec"
	id-iteration [string!] "identifiant de l'it�ration"
] [
	id-iteration
	either not attempt [
		object-iteration: load-iteration id-iteration
		either (object-iteration = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return object-iteration/date-begining
	]
]
get-state-iteration-numeric: func [
	"calcule l'�tat d'une it�ration dont on passe l'identifiant en param�tre"
	id-iteration [string!] "identifiant de l'it�ration"
] [

	either not attempt
	[
		object-iteration: load-iteration id-iteration
		if (object-iteration = false) [return false]
		story-serie: object-iteration/stories-iteration
		forskip story-serie 2
		[
			get-state-story-numeric story-serie/1
		]
		undone: 0
		done: 0
		forskip story-serie 2
		[
			object-story: load-story story-serie/1
			either (object-story/my-story-state = "done")
			[done: done + 1]
			[undone: undone + 1]
		]
		state: (done / (undone + done))
		return true
	]
	[
		return 0
	]
	[
		return state
	]
]
get-state-iteration: func [
	"calcule l'�tat d'une it�ration dont on passe l'identifiant en param�tre"
	id-iteration [string!] "identifiant de l'it�ration"
] [
	either not attempt
	[
		object-iteration: load-iteration id-iteration
		story-serie: object-iteration/stories-iteration
		if (object-iteration = false) [return false]
		forskip story-serie 2
		[
			get-state-story-numeric story-serie/1
		]
		undone: 0
		done: 0

		forskip story-serie 2
		[
			story-serie
			object-story: load-story story-serie/1
			either (object-story/my-story-state = "done")
			[done: done + 1]
			[undone: undone + 1]
		]
		state: join 100 * (done / (undone + done)) " %"
		either (state = "100 %")
		[
			object-iteration/state: "done"
		]
		[
			object-iteration/state: "iddle"
		]
		save-iteration to-file join id-iteration ".o" object-iteration
		return true
	]
	[
		return "0 %"
	]
	[
		return state
	]
]

;donn�es de la story

;�tat en num�rique

get-state-story-numeric: func [
	"retourne l'�tat de la story en num�rique"
	id-story [string!]
] [
	wrong-fields: copy []
	either not attempt
	[
		object-story: load-story id-story
		if (object-story = false) [return 0]

		tasks-serie: object-story/tasks-pool
		forskip tasks-serie 2 [get-state-task-numeric tasks-serie/1]
		undone: 0
		done: 0
		forskip tasks-serie 2
		[
			object-task: load-task tasks-serie/1
			either (object-task/task-state = "done")
			[done: done + 1]
			[undone: undone + 1]
		]

		state: (done / (undone + done))
		either (state = 1)
		[
			object-story/my-story-state: "done"
		]
		[
			object-story/my-story-state: "iddle"
		]
		save-story to-file join id-story ".o" object-story
		return true
	]
	[
		return 0
	]
	[
		return state
	]
]

;etat sous forme de chaine de caract�re
get-state-story: func [
	"retourne l'�tat de la story en num�rique"
	id-story [string!]
] [
	wrong-fields: copy []
	either not attempt
	[
		object-story: load-story id-story
		if (object-story = false) [return 0]
		undone: 0
		done: 0
		tasks-serie: object-story/tasks-pool
		forskip tasks-serie 2
		[
			object-task: load-task tasks-serie/1
			either (object-task/task-state = "done")
			[done: done + 1]
			[undone: undone + 1]
		]
		state: 100 * (done / (undone + done))
		if (state = 1) [
			object-story/my-story-state: "done"
			save-story to-file join id-story ".o" object-story

		]
		return true
	]
	[
		return "0 %"
	]
	[
		return join state "%"
	]
]



;titre
get-story-title: func [
	"retourne le titre de la story ou une chaine vide si �chec"
	id-story [string!]
] [
	either not attempt [
		object-story: load-story id-story
		either (object-story = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return object-story/title-story
	]
]

;date

get-story-date: func [
	"retourne la date de creation de la story ou une chaine vide si �chec"
	id-story [string!]
] [
	either not attempt [
		object-story: load-story id-story
		either (object-story = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return object-story/date-story
	]
]

;estimation

get-story-estimate: func [
	"retourne l'estimation de la story ou une chaine vide si �chec"
	id-story [string!]
] [
	either not attempt [
		object-story: load-story id-story
		either (object-story = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return to-string object-story/estimate-story
	]
]

;description

get-story-description: func [
	"retourne la description de la story ou une chaine vide si �chec"
	id-story [string!]
] [
	either not attempt [
		object-story: load-story id-story
		either (object-story = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return to-string object-story/description-story
	]
]

;risque

get-story-tech-risk: func [
	"retourne le risque technique de la story ou une chaine vide si �chec"
	id-story [string!]
] [
	either not attempt [
		object-story: load-story id-story
		either (object-story = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return to-string object-story/risk-story
	]
]

;priorit� technique

get-story-tech-priority: func [
	"retourne la priorit� technique de la story ou une chaine vide si �chec"
	id-story [string!]
] [
	either not attempt [
		object-story: load-story id-story
		either (object-story = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return to-string object-story/tech-prior-story
	]
]

;priorit� utilisateur

get-story-user-priority: func [
	"retourne la priorit� utilisateur de la story ou une chaine vide si �chec"
	id-story [string!]
] [
	either not attempt [
		object-story: load-story id-story
		either (object-story = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return to-string object-story/user-prior-story
	]
]
;donn�es de la task
;date
get-date-task: func [
	"retourne la date de la task"
	id-task [string!] "identifiant de la task"
] [
	either not attempt [
		object-task: load-task id-task
		retour: to-string object-task/date-task
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

;title
get-title-task: func [
	"retourne le titre de la task"
	id-task [string!] "identifiant de la task"
] [
	either not attempt [
		object-task: load-task id-task
		retour: to-string object-task/title-task
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

;story
get-story-task: func [
	"retourne le story de la task"
	id-task [string!] "identifiant de la task"
] [
	either not attempt [
		object-task: load-task id-task
		retour: to-string object-task/story-task
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]
; entr�es

get-in-task: func [
	"retourne les entr�es de la task"
	id-task [string!] "identifiant de la task"
] [
	either not attempt [
		object-task: load-task id-task
		retour: object-task/in-task
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]
;state

get-state-task: func [
	"calcule l'�tat d'une task dont on passe l'identifiant en param�tre"
	id-task [string!] "identifiant de la task"
]
[

	either not attempt
	[
		object-task: load-task id-task
		if (object-task = false) [return "0 %"]
		undone: 0
		done: 0
		tests-serie: object-task/task-tests
		foreach el tests-serie
		[
			object-test: load-test el
			either (object-test/test-state = "done")
			[done: done + 1]
			[undone: undone + 1]
		]
		state: join 100 * (done / (done + undone)) " %"
		return true
	]
	[
		return "0%"
	]
	[
		return state
	]
]
;state-numeric

get-state-task-numeric: func [
	"retourne l'�tat de la task en num�rique"
	id-task [string!]
] [
	wrong-fields: copy []
	either not attempt
	[
		object-task: load-task id-task
		if (object-task = false) [return 0]
		undone: 0
		done: 0
		tests-serie: object-task/task-tests
		foreach el tests-serie
		[
			object-test: load-test el
			either (object-test/test-state = "done")
			[done: done + 1]
			[undone: undone + 1]
		]
		state: (done / (undone + done))
		either (state = 1)
		[
			object-task/task-state: "done"
		]
		[
			object-task/task-state: "iddle"
		]
		object-task/task-state
		save-task to-file join id-task ".o" object-task
		return true
	]
	[
		return 0
	]
	[

		return state
	]
]


; sorties

get-out-task: func [
	"retourne les entr�es de la task"
	id-task [string!] "identifiant de la task"
] [
	either not attempt [
		object-task: load-task id-task
		retour: object-task/out-task
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

;responsabilities

get-responsabilities-task: func [
	"retourne les entr�es de la task"
	id-task [string!] "identifiant de la task"
] [
	either not attempt [
		object-task: load-task id-task
		retour: object-task/responsabilities-task
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

;collaborations

get-collaborations-task: func [
	"retourne les entr�es de la task"
	id-task [string!] "identifiant de la task"
] [
	either not attempt [
		object-task: load-task id-task
		retour: to-string object-task/collaborations-task
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

;donn�e du test

get-task-test: func [
	"retourne la task qui contient le test ou une chaine vide si �chec"
	id-test [string!]
] [
	either not attempt [
		object-test: load-test id-test
		either (object-test = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return object-test/task-test
	]
]

get-in-test: func [
	"retourne les entr�es du test"
	id-test [string!] "identifiant du test"
] [
	either not attempt [
		object-test: load-test id-test
		retour: object-test/in-test
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

get-out-test: func [
	"retourne les sorties du test"
	id-test [string!] "identifiant du test"
] [
	either not attempt [
		object-test: load-test id-test
		retour: object-test/out-test
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

get-summary-test: func [
	"retourne la description du test"
	id-test [string!] "identifiant du test"
] [
	either not attempt [
		object-test: load-test id-test
		retour: object-test/description-test
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

get-story-test: func [
	"retourne la story du test"
	id-test [string!] "identifiant du test"
] [
	either not attempt [
		object-test: load-test id-test
		retour: object-test/story-test
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

get-date-test: func [
	"retourne la date de cr�ation du test"
	id-test [string!] "identifiant du test"
] [
	either not attempt [
		object-test: load-test id-test
		retour: object-test/date-test
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

get-state-test: func [
	"retourne l'�tat de cr�ation du test"
	id-test [string!] "identifiant du test"
] [
	either not attempt [
		object-test: load-test id-test
		retour: object-test/test-state
		return true
	]
	[
		return ""
	]
	[
		return retour
	]
]

get-pre-cond-test: func [
	"retourne la pr�condition du test ou une chaine vide si �chec"
	id-test [string!]
] [
	either not attempt [
		object-test: load-test id-test
		either (object-test = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return object-test/pre-cond-test
	]
]

get-post-cond-test: func [
	"retourne la postcondition du test ou une chaine vide si �chec"
	id-test [string!]
] [
	either not attempt [
		object-test: load-test id-test
		either (object-test = false)
		[return false]
		[return true]
	]
	[
		return ""
	]
	[
		return object-test/pre-cond-test
	]
]

;fonction qui vont mettre une donn�e dans une s�rie (set) en attente d'etre r�cup�r�e pour la vue

set-name-user: func [
	"initialise le user logged"
	name [string!] "nom de l'utilisateur venant de se logguer"
]
[
	either not attempt
	[
		append user-logged name
		return true
	]
	[
		return false
	]
	[
		return true
	]
]


;fonctions qui suppriment quelque chose
;iteration
delete-iteration: func [
	"d�truit une it�ration sur le disque"
	id-iteration-di [string!] "identifiant de l'it�ration"
] [
	either not attempt [
		object-project: load-project
		serie-it-di: object-project/iterations
		l1: length? serie-it-di
		l2: length? test: find serie-it-di id-iteration-di
		val1: l1 - l2 + 1
		val2: val1 + 1
		poke serie-it-di val1 69
		poke serie-it-di val2 69
		remove-each el serie-it-di [el = 69]
		object-project/iterations: copy serie-it-di
		save-project object-project
		erase-iteration id-iteration-di
		return true
	]
	[
		append I-O-problem join "problem with the destruction of iteration " id-iteration-di
		return false
	]
	[
		return true
	]
]
; story
delete-story: func [
	"d�truit une it�ration sur le disque"
	id-story [string!] "identifiant de la story"
] [
	either not attempt [
		object-project: load-project
		serie-st-di: object-project/stories-pool
		l1: length? serie-st-di
		l2: length? test: find serie-st-di id-story
		val1: l1 - l2 + 1
		val2: val1 + 1
		poke serie-st-di val1 69
		poke serie-st-di val2 69
		remove-each el serie-st-di [el = 69]
		object-project/stories-pool: copy serie-st-di
		save-project object-project
		erase-story id-story
		return true
	]
	[
		append I-O-problem join "problem with the destruction of story " id-story
		return false
	]
	[
		return true
	]
]
;check
check-companion: func [
	"v�rifie si le binome est dans le projet"
	name-companion [string!] "nom du binome"
] [

	either not attempt
	[
		either (not empty? name-companion)
		[
			object-project: load-project
			find object-project/users name-companion
			return true
		]
		[
			name-companion: "alone"
			return true
		]
	]
	[return false]
	[return true]
]
;task
delete-task: func [
	"d�truit une it�ration sur le disque"
	id-task [string!] "identifiant de la task"
] [
	I-O-problem: copy []
	either not attempt [
		object-task: load-task id-task
		object-story: load-story object-task/story-task/1
		serie-st-di: object-story/tasks-pool
		l1: length? serie-st-di
		l2: length? test: find serie-st-di id-task
		val1: l1 - l2 + 1
		val2: val1 + 1
		poke serie-st-di val1 69
		poke serie-st-di val2 69
		remove-each el serie-st-di [el = 69]
		object-story/tasks-pool: copy serie-st-di
		save-story to-file join object-task/story-task/1 ".o" object-story
		erase-task id-task
		return true
	]
	[
		append I-O-problem join "problem with the destruction of task " id-task
		return false
	]
	[
		return true
	]
]

delete-test: func [
	"d�truit un test sur le disque"
	id-test [string!] "identifiant du test"
] [
	I-O-problem: copy []
	either not attempt [
		object-test: load-test id-test
		object-task: load-task object-test/task-test
		serie-st-di: object-task/task-tests
		l1: length? serie-st-di
		l2: length? test: find serie-st-di id-test
		val1: l1 - l2 + 1
		poke serie-st-di val1 69
		remove-each el serie-st-di [el = 69]
		object-task/task-tests: copy serie-st-di
		save-task to-file join object-test/task-test ".o" object-task
		erase-test id-test
		return true
	]
	[
		append I-O-problem join "problem with the destruction of test " id-test
		return false
	]
	[
		return true
	]
]

;fonctions qui lient des �l�ments

;story-iteration

add-story-iteration: func [
	"ajoute une story dans une it�ration"
	id-story [string!] "identifiant de la story"
	id-iteration [string!] "identifiant de l'it�ration"
] [
	either not attempt [
		wrong-fields: copy []
		object-iteration: load-iteration id-iteration
		object-story: load-story id-story
		either not attempt [find object-iteration/stories-iteration id-story]
		[
			append object-iteration/stories-iteration id-story
			append object-iteration/stories-iteration object-story/title-story
			append object-story/my-story-iterations id-iteration
			save-story to-file join id-story ".o" object-story
			save-iteration to-file join id-iteration ".o" object-iteration
			return true
		]
		[
			return false
		]
	]
	[

		append wrong-fields "problem with the link of the story and the iteration"
		return false
	]
	[
		return true
	]
]
take-task: func [
	"prendre la task et inscrire le user logged dans le log qui l'a prise, son binome et l'heure"
	id-task [string!]
]
[
	either not attempt [
		object-task: load-task id-task
		either (empty? object-task/log) and (empty? working-task)
		[
			append object-task/log user-logged/1
			append object-task/log companion/1
			append object-task/log now/time
			append working-task id-task
			save-task to-file join id-task ".o" object-task
		]
		[
			return false
		]
	]
	[return false]
	[return true]
]
leave-task-prod-code: func [
	"mettre le journal en ordre stable et cloturer la task"
]
[
	either not attempt [
		object-task: load-task working-task/1
		time-elapsed: object-task/log/3 - now/time
		append object-task/log time-elapsed
		save-task to-file join working-task/1 ".o" object-task
		working-task: copy []
		return true
	]
	[return false]
	[return true]
]
leave-task-spikes: func [
	"mettre a blanc le log"
]
[
	either not attempt [
		object-task: load-task working-task/1
		object-task/log: copy []
		save-task to-file join working-task/1 ".o" object-task
		working-task: copy []
		return true
	]
	[return false]
	[return true]
]

;feuille de style
general-styles: stylize
[
	;styles de textes
	my-title-text: text underline black font-size 16
	my-text: text black font-size 16
	my-big-text: text black font-size 32
	my-red-text: text red font-size 16
	;styles d'aires de texte
	my-area: area 350x50
	my-area-task: area 150x40
	;styles de labels
	my-title-label: label black font-size 16
	my-big-label: label black font-size 20
	my-label: label black
	my-label-task: label black 40x20
	;styles de fields
	my-field: field ivory
	my-field-task: field ivory 150x20
	my-field-small: field ivory 80x20
	my-field-date: field ivory 70x20
	my-field-number: field ivory 30x20
	;styles de controles
	my-button: button ivory
	;mes styles d'info
	my-info-date: info ivory 70x20
	my-info: info ivory
	my-info-number: info ivory 30x20
	my-info-area: info ivory 350x50
	;style de progress bar
	my-progress: progress green blue 100x20
]

;fonction qui g�n�re des layouts
simple-layout-generator: func [
	"g�n�re les �crans en utilisant accross, below, return et tab"
	sty [logic!] "param�tre permettant la pr�sence ou non de la feuille de style"
	fond [tuple!] "tuple contenant la couleur de fond du layout"
	taille [pair!] "taille du layout"
	elements [block!] "elements du layout"

] [
	fen: copy []
	if (sty) [append fen compose [styles general-styles]]
	append fen reduce ['size taille]
	append fen reduce ['backdrop fond]
	foreach component elements [
		append fen component/1
		;structure d'un bloc: nom [string!] type [style!] contenu [string!] fonction [block!] ou bien return
		foreach el component/2 [
			either (string? el)
			[append fen to-word el]
			[
				append fen to-set-word el/1
				append fen el/2
				append fen el/3
				append fen reduce [either (block? el/4) [el/4] [""]]
			]

		]
	]
]



;fenetre principale
main-layout: func [
	"g�n�re l'�cran qui supporte les autres"
] [
	;fonctions g�n�rant des layouts de forums venant se greffer sur la fenetre principale

	;forum d'iteration 
	forum-iteration: func [
		"cree un layout qui g�re les pages d'it�rations a la mani�re d'un forum"
		page-vis [integer!] "num�ro de la page qui doit etre visible"
	] [
		use [] [
			forum-iteration-layout: copy []
			forum-iteration-layout: copy [
				size 500x225
				backdrop ivory
				across
				at 50x2 label black "iterations"
				at 0x50 boite: box ivory 500x200
				do [
					boite/pane: layout/offset/origin management-page-iteration-layout page-vis serie-iter 0x0 0x0
				]
				at 5x25
			]
			object-project: load-project
			serie-iter: object-project/iterations
			;calcul du nombre de pages
			nb-pages: round/ceiling / length? serie-iter 10
			for i 1 nb-pages 1
			[
				append forum-iteration-layout compose/deep [text blue (to-string i) [boite/pane: layout/offset/origin management-page-iteration-layout (i) serie-iter 0x0 0x0 show boite]]
			]
		]
		return forum-iteration-layout
	]
	;forum-story 
	forum-story: func [
		"cree un layout qui g�re les pages de story a la mani�re d'un forum"
		page-vis [integer!] "num�ro de la page qui doit etre visible"
	] [
		forum-story-layout: copy []
		forum-story-layout: copy [
			size 500x225
			backdrop ivory
			across
			at 50x2 label black "Stories"
			at 0x50 boite: box ivory 500x200
			do [
				boite/pane: layout/offset/origin management-page-stories-layout page-vis serie-stories 0x0 0x0
			]
			at 5x25
		]
		object-project: load-project
		serie-stories: object-project/stories-pool
		;calcul du nombre de pages
		nb-pages: round/ceiling / length? serie-stories 10
		for i 1 nb-pages 1
		[
			append forum-story-layout compose/deep [text blue (to-string i) [boite/pane: layout/offset/origin management-page-stories-layout (i) serie-stories 0x0 0x0 show boite]]
		]
		return forum-story-layout
	]

	forum-story-add: func [
		"cree un layout qui g�re les pages de story a la mani�re d'un forum"
		page-vis [integer!] "num�ro de la page qui doit etre visible"
		id-iteration [string!] "identifiant de l'it�ration a laquelle on peut rattacher la story"
	] [
		forum-story-layout: copy []
		forum-story-layout: copy [
			size 500x225
			backdrop ivory
			across
			at 50x2 label black "Stories"
			at 0x50 boite: box ivory 500x200
			do [
				boite/pane: layout/offset/origin management-page-stories-add-layout page-vis serie-stories id-iteration 0x0 0x0
			]
			at 5x25
		]
		object-project: load-project
		serie-stories: object-project/stories-pool
		;calcul du nombre de pages
		nb-pages: round/ceiling / length? serie-stories 10
		for i 1 nb-pages 1
		[
			append forum-story-layout compose/deep [text blue (to-string i) [boite/pane: layout/offset/origin management-page-stories-add-layout (i) serie-stories id-iteration 0x0 0x0 show boite]]
		]
		return forum-story-layout
	]
	forum-story-iteration: func [
		"cree un layout qui g�re les pages de story rattach�e a une iteration a la mani�re d'un forum"
		id-iteration [string!] "identifiant de l'it�ration"
		page-vis [integer!] "num�ro de la page qui doit etre visible"
	] [
		forum-story-layout: copy []
		forum-story-layout: copy [
			size 500x225
			backdrop ivory
			across
			at 50x2 label black "Stories"
			at 0x50 boite: box ivory 500x200
			do [
				boite/pane: layout/offset/origin management-page-stories-layout page-vis serie-stories 0x0 0x0
			]
			at 5x25
		]
		object-iteration: load-iteration id-iteration
		serie-stories: object-iteration/stories-iteration
		;calcul du nombre de pages
		nb-pages: round/ceiling / length? serie-stories 10
		for i 1 nb-pages 1
		[
			append forum-story-layout compose/deep [text blue (to-string i) [boite/pane: layout/offset/origin management-page-stories-layout (i) serie-stories 0x0 0x0 show boite]]
		]
		return forum-story-layout
	]


	;forum de tasks
	forum-task: func [
		"pr�sente les tasks comme dans un forum"
		id-story [string!] "identifiant de la story a laquelle sont rattach�es les tasks"
		page-vis [integer!] "num�ro de la page qui doit etre visible"
	] [
		forum-tasks-layout: copy [
			size 500x225
			backdrop ivory
			across
			at 50x2 label black "Tasks"
			at 0x50 boite: box ivory 500x200
			do [
				boite/pane: layout/offset/origin management-page-tasks-layout page-vis serie-tasks 0x0 0x0
			]
			at 5x25
		]
		object-story: load-story id-story
		serie-tasks: object-story/tasks-pool
		;calcul du nombre de pages
		nb-pages: round/ceiling / length? serie-tasks 10
		for i 1 nb-pages 1
		[
			append forum-tasks-layout compose/deep [text blue (to-string i) [boite/pane: layout/offset/origin management-page-tasks-layout (i) serie-tasks 0x0 0x0 show boite]]
		]
		return forum-tasks-layout
	]

	; forum de tests

	forum-test: func [
		"pr�sente les tests comme dans un forum"
		id-task [string!] "identifiant de la task a laquelle sont rattach�es les tests"
		page-vis [integer!] "num�ro de la page qui doit etre visible"
	] [

		forum-tests-layout: copy [
			size 500x225
			backdrop ivory
			across
			at 50x2 label black "Tests"
			at 0x50 boite: box ivory 500x200
			do [
				boite/pane: layout/offset/origin management-page-tests-layout page-vis serie-tests 0x0 0x0
			]
			at 5x25
		]
		object-task: load-task id-task
		serie-tests: object-task/task-tests
		;calcul du nombre de pages
		nb-pages: round/ceiling / length? serie-tests 10
		for i 1 nb-pages 1
		[
			append forum-tests-layout compose/deep [text blue (to-string i) [boite/pane: layout/offset/origin management-page-tests-layout (i) serie-tests 0x0 0x0 show boite]]
		]
		return forum-tests-layout
	]
	;forum de test

	forum-test-working: func [
		"pr�sente les tests comme dans un forum"
		id-task [string!] "identifiant de la task a laquelle sont rattach�es les tests"
		page-vis [integer!] "num�ro de la page qui doit etre visible"
	] [
		forum-tests-layout: copy [
			size 500x225
			backdrop ivory
			across
			at 50x2 label black "Tests"
			at 0x50 boite: box ivory 500x200
			do [
				boite/pane: layout/offset/origin management-page-tests-taken-layout page-vis serie-tests 0x0 0x0
			]
			at 5x25
		]
		object-task: load-task id-task
		serie-tests: object-task/task-tests
		;calcul du nombre de pages
		nb-pages: round/ceiling / length? serie-tests 10
		for i 1 nb-pages 1
		[
			append forum-tests-layout compose/deep [text blue (to-string i) [boite/pane: layout/offset/origin management-page-tests-layout (i) serie-tests 0x0 0x0 show boite]]
		]
		return forum-tests-layout
	]




	;fonctions qui produisent des pages de management


	;fonction qui produit une page de management d'iteration
	management-page-iteration-layout: func [
		"cree un bloc de layout de page de 5 lignes"
		num-page [integer!] "num�ro de la page"
		serie-object [block!] "serie a paginer"
	] [

		page: copy [backdrop ivory size 500x200 tab across]
		num-prem-ligne: (10 * (num-page - 1)) + 1
		serie-it: at serie-object num-prem-ligne
		for i 1 10 2
		[
			j: i + 1
			id-object: to-string serie-it/:i
			name-object: to-string serie-it/:j
			either (not id-object = "none") [append page compose/deep management-line-iteration-layout id-object name-object] [append page compose []]
		]
		return page
	]


	;fonction qui produit une page de management de story


	management-page-stories-layout: func [
		"cree un bloc de layout de page de 5 lignes"
		num-page [integer!] "num�ro de la page"
		serie-object [block!] "serie a paginer"

	] [
		page: copy [backdrop ivory size 500x200 tab across]
		num-prem-ligne: (10 * (num-page - 1)) + 1
		serie-it: at serie-object num-prem-ligne
		for i 1 10 2
		[
			j: i + 1
			id-object: to-string serie-it/:i
			name-object: to-string serie-it/:j
			either (not id-object = "none") [append page compose/deep management-line-story-layout id-object name-object] [append page compose []]
		]
		return page
	]

	management-page-stories-add-layout: func [
		"cree un bloc de layout de page de 5 lignes qui permet l'ajout d'une story a une it�ration"
		num-page [integer!] "num�ro de la page"
		serie-object [block!] "serie a paginer"
		id-iteration [string!] "identifiant de l'it�ration"

	] [
		page: copy [backdrop ivory size 500x200 tab across]
		num-prem-ligne: (10 * (num-page - 1)) + 1
		serie-it: at serie-object num-prem-ligne
		for i 1 10 2
		[
			j: i + 1
			id-object: to-string serie-it/:i
			name-object: to-string serie-it/:j
			either (not id-object = "none") [append page compose/deep management-line-story-add-layout id-object name-object id-iteration] [append page compose []]
		]
		return page
	]

	;tasks-management

	management-page-tasks-layout: func [
		"cree un bloc de layout de page de 5 lignes"
		num-page [integer!] "num�ro de la page"
		serie-object [block!] "serie a paginer"
	] [

		page: copy [backdrop ivory size 500x200 tab across]
		num-prem-ligne: (10 * (num-page - 1)) + 1
		serie-it: at serie-object num-prem-ligne
		for i 1 10 2
		[
			j: i + 1
			id-object: to-string serie-it/:i
			name-object: to-string serie-it/:j
			either (not id-object = "none") [append page compose/deep management-line-tasks-layout id-object name-object] [append page compose []]
		]
		return page
	]

	management-page-tests-layout: func [
		"cree un bloc de layout de page de 5 lignes"
		num-page [integer!] "num�ro de la page"
		serie-object [block!] "serie a paginer"
	] [

		page: copy [backdrop ivory size 500x200 tab across]
		num-prem-ligne: (10 * (num-page - 1)) + 1
		serie-it: at serie-object num-prem-ligne
		for i 1 5 1
		[
			j: i + 1
			id-object: to-string serie-it/:i
			name-object: to-string serie-it/:j
			either (not id-object = "none") [append page compose/deep management-line-tests-layout id-object name-object] [append page compose []]
		]
		return page
	]

	management-page-tests-taken-layout: func [
		"cree un bloc de layout de page de 5 lignes"
		num-page [integer!] "num�ro de la page"
		serie-object [block!] "serie a paginer"
	] [

		page: copy [backdrop ivory size 500x200 tab across]
		num-prem-ligne: (10 * (num-page - 1)) + 1
		serie-it: at serie-object num-prem-ligne
		for i 1 5 1
		[
			j: i + 1
			id-object: to-string serie-it/:i
			name-object: to-string serie-it/:j
			either (not id-object = "none") [append page compose/deep management-line-tests-taken-layout id-object name-object] [append page compose []]
		]
		return page
	]



	;fonctions qui produit une ligne de page de management d'iteration
	management-line-iteration-layout: func [
		"cree une ligne de layout pour une page"
		id-iteration [string!] "identifiant d'une iteration"
		name-iteration [string!] "nom d'une iteration"
	] [
		use [line]
		[
			line: copy []
			append line compose/deep
			[
				name-obj-f-l: text (name-iteration) 80x25 [
					lay: iteration-presentation (id-iteration)
					mid/pane: layout/offset/origin lay 0x0 5x5
					show mid
					end/pane: layout/offset/origin forum-story-iteration (id-iteration) 1 0x0 5x5
					show end
				]
				tab
				btn-mod-f-l: btn "modify" [

					m-lay: modify-iteration-layout (id-iteration)
					mid/pane: layout/offset/origin m-lay 0x0 5x5
					show mid

				]
				tab
				btn-sup-f-l: btn "delete" [
					destruction: request/confirm "do you want to delete the iteration ?"
					if destruction
					[
						delete-iteration (id-iteration)
						end/pane: layout/offset/origin forum-iteration 1 0x0 5x5 show end

					]


				]
				tab
				inf-st-f-l: info (get-state-iteration id-iteration) 60x20
				prog-st-f-l: progress red blue 100x20 do [prog-st-f-l/data: get-state-iteration-numeric (id-iteration) show prog-st-f-l]
				return
			]
			return line
		]
	]

	;fonctions qui produit une ligne de page de management de story

	management-line-story-layout: func [
		"cree une ligne de layout pour une page"
		id-story [string!] "identifiant d'une story"
		name-story [string!] "nom d'une story"

	] [

		use [line]
		[

			line: copy []
			append line compose/deep
			[
				name-obj-f-l: text (name-story) 80x25 [
					lay: story-presentation (id-story)
					mid/pane: layout/offset/origin lay 0x0 5x5
					show mid
					end/pane: layout/offset/origin forum-task (id-story) 1 0x0 5x5
					show end
				]
				btn-mod-f-l: btn "modify" [
					m-lay: modify-story-layout (id-story)
					mid/pane: layout/offset/origin m-lay 0x0 5x5
					show mid

				]
				btn-sup-f-l: btn "delete" [
					destruction: request/confirm "do you want to supress the story ?"
					if destruction
					[
						delete-story (id-story)
						end/pane: layout/offset/origin forum-story 1 0x0 5x5 show end

					]
				]
				btn-add-task-f-l: btn "add task" [

					mid/pane: layout/offset/origin create-task-layout (id-story) 0x0 5x5 show mid


				]

				inf-st-f-l: info (get-state-story id-story) 60x20
				prog-st-f-l: progress red blue 100x20 do [prog-st-f-l/data: get-state-story-numeric (id-story) show prog-st-f-l]
				return
			]
			return line
		]
	]

	management-line-story-add-layout: func [
		"cree une ligne de layout pour une page avec une possibilit� d'ajouter la story a l'it�ration"
		id-story [string!] "identifiant d'une story"
		name-story [string!] "nom d'une story"
		id-iteration [string!] "identifiant de l'it�ration"
	] [

		use [line]
		[
			line: copy []
			append line compose/deep
			[
				name-obj-f-l: text (name-story) 80x25 [
					lay: story-presentation (id-story)
					mid/pane: layout/offset/origin lay 0x0 5x5
					show mid
					end/pane: layout/offset/origin forum-story 1 0x0 5x5
					show end
				]
				btn-mod-f-l: btn "modify" [
					m-lay: modify-story-layout (id-story)
					mid/pane: layout/offset/origin m-lay 0x0 5x5
					show mid

				]
				btn-sup-f-l: btn "delete" [
					destruction: request/confirm "do you want to supress the story ?"
					if destruction
					[
						delete-story (id-story)
						end/pane: layout/offset/origin forum-story 1 0x0 5x5 show end

					]

				]
				btn-sup-f-l: btn "add" [
					addition: request/confirm "do you want to add story ?"
					if addition
					[
						either not attempt [
							add-story-iteration (id-story) (id-iteration)
						]
						[
							foreach el wrong-fields [alert el]
							return false
						]
						[
							return true
						]
					]

				]
				inf-st-f-l: info (get-state-story id-story) 60x20
				prog-st-f-l: progress red blue 100x20 do [prog-st-f-l/data: get-state-story-numeric (id-story) show prog-st-f-l]
				return
			]
			return line
		]
	]

	;ligne de page de management de task

	management-line-tasks-layout: func [
		"cree une ligne de layout pour une page de tasks"
		id-task [string!] "identifiant d'une task"
		name-task [string!] "nom d'une task"
	] [
		object-task: load-task id-task
		id-story: object-task/story-task/1
		use [line]
		[
			line: copy []
			append line compose/deep
			[
				name-obj-f-l: text (name-task) 80x25 [
					lay: task-presentation (id-task)
					mid/pane: layout/offset/origin lay 0x0 5x5
					show mid
					end/pane: layout/offset/origin forum-test (id-task) 1 0x0 5x5
					show end
				]

				btn-mod-f-l: btn "modify" [

					m-lay: modify-task-layout (id-task)
					mid/pane: layout/offset/origin m-lay 0x0 5x5
					show mid
					end/pane: layout/offset/origin forum-test (id-task) 1 0x0 5x5
					show end

				]
				btn-sup-f-l: btn "delete" [
					destruction: request/confirm "do you want to delete this task ?"
					if destruction
					[
						delete-task (id-task)
						end/pane: layout/offset/origin forum-task (id-story) 1 0x0 5x5 show end

					]
				]

				btn-add-f-l: btn "add test" [
					mid/pane: layout/offset/origin create-test-layout id-task 0x0 5x5 show mid
				]

				btn-add-f-l: btn "take me" [
					mid/pane: layout/offset/origin take-task-layout id-task 0x0 5x5 show mid
				]

				inf-st-f-l: info (get-state-task id-task) 60x20
				prog-st-f-l: progress red blue 100x20 do [prog-st-f-l/data: get-state-task-numeric (id-task) show prog-st-f-l]
				return
			]
			return line
		]
	]

	management-line-tests-layout: func [
		"cree une ligne de layout pour une page de tests"
		id-test [string!] "identifiant d'un test"
	] [
		name-test: "test"
		object-test: load-test id-test
		id-task: object-test/task-test
		use [line]
		[
			line: copy []
			append line compose/deep
			[

				name-obj-f-t: text (name-test) 80x25 [
					lay: test-presentation (id-test)
					mid/pane: layout/offset/origin lay 0x0 5x5 show mid
					end/pane: layout/offset/origin [box 500x200 ivory] 0x0 5x5 show end
				]


				btn-sup-f-t: btn "delete" [
					del: request/confirm "do you want to delete this test ?"
					if del
					[
						delete-test (id-test)
						end/pane: layout/offset/origin forum-test (id-task) 1 0x0 5x5 show end
					]
				]
				chk-val-f-t: check [

					validate-modified-state-test (id-test)
					end/pane: layout/offset/origin forum-test (id-task) 1 0x0 5x5 show end
				]
				info-test: info (get-state-test id-test) 60x20
				return

			]
			return line
		]
	]

	management-line-tests-taken-layout: func [
		"cree une ligne de layout pour une page de tests"
		id-test [string!] "identifiant d'un test"

	] [
		name-test: "test"
		object-test: load-test id-test
		id-task: object-test/task-test
		use [line]
		[
			line: copy []
			append line compose/deep
			[

				name-obj-f-t: text (name-test) 80x25 [
					lay: test-taken-presentation (id-test)
					mid/pane: layout/offset/origin lay 0x0 5x5
					show mid
					hide end

				]


				btn-sup-f-t: btn "delete" [
					del: request/confirm "do you want to delete this test ?"
					if del
					[
						delete-test (id-test)
						end/pane: layout/offset/origin forum-test (id-task) 1 0x0 5x5 show end
					]
				]
				chk-val-f-t: check [

					validate-modified-state-test (id-test)
					end/pane: layout/offset/origin forum-test (id-task) 1 0x0 5x5 show end
				]
				info-test: info (get-state-test id-test) 60x20
				return

			]
			return line
		]
	]

	;ecrans de projet
	;ecran de modification d'un projet

	modify-project-layout: func ["fonction qui g�n�re un layout de modification du projet"] [



		modify-project: simple-layout-generator true ivory 500x200 [
			[
				below
				[
					[first-time my-label "modification of the project"]
				]
			]
			[
				across
				[
					[project-label my-label "project :"]
					"tab"
					[name-project-modified-field my-field get-project-name]
					"return"
					[date-label my-label "begining :"]
					"tab"
					[date-project-modified-info my-info get-project-date [my-date: request-date date-project-modified-info/text: my-date show date-project-modified-info]]
					"return"
					[desc-label my-label "summary :"]
					"tab"
					[description-project-modified-area my-area get-project-description]
					"return"
					[
						validate my-button "validate" [either (validate-project-modified name-project-modified-field/text description-project-modified-area/text to-date date-project-modified-info/text)
							[
								;affichage des champs
								;modification de la chaine de caractere du titre
								proj-info-logo/text: get-project-name
								name-project-field/text: get-project-name
								date-info/text: get-project-date
								description-area/text: get-project-description
								show proj-info-logo
								proj-info-logo/text
							]
							[
								;affichage des champs echou�s
								proj-info-logo/text: get-project-name
								name-project-field/text: get-project-name
								date-info/text: get-project-date
								description-area/text: get-project-description
								foreach el wrong-fields [alert el]
								foreach el I-O-problem [alert el]
							]
						]
					]
				]
			]
		]
		return modify-project
	]


	;ecran de pr�sentation du projet
	project-presentation-layout: func ["fonction qui g�n�re le layout de pr�sentation du projet"] [

		project-presentation: simple-layout-generator true ivory 500x200 [
			[
				across
				[
					[title-label my-label "project presentation"]
					"return"
					[project-label my-label "project :"]
					"tab"
					[name-project-field my-info get-project-name]
					"return"
					[desc-label my-label "begining :"]
					[date-info my-info-date get-project-date]
					[project-label my-label "state :"]
					[state-project-field my-info-date get-state-project]
					"tab"
					[state-project-progress my-progress do [state-project-progress/data: test: get-state-project-numeric show state-project-progress]]
					"return"
					[desc-label my-label "summary :"]
					"tab"
					[description-area my-info-area get-project-description]
					"return"
					[
						modify my-button "modify" ["gerer l'affichage du panneau de modif du projet"
							mid/pane: layout/offset/origin modify-project-layout 0x0 5x5
							show mid
							end/pane: layout/offset/origin forum-iteration 1 0x0 5x5
							show end
						]
					]

				]
			]
		]
	]



	;�crans d'it�ration
	;ecran de creation d'une iteration
	create-iteration-layout: func ["cree l'�cran d'une it�ration"] [
		use [field1 field2] [
			field1: copy ""
			field2: copy ""

			create-iteration-lay: simple-layout-generator true ivory 500x200 [
				[
					below
					[
						[first-time my-label "Iteration creation"]
					]
				]
				[
					across
					[
						[begining-cil my-label "begining"]
						[begining-field-cil my-info-date "" [my-date: request-date begining-field-cil/text: to-string my-date show begining-field-cil]]
						[end-cil my-label "end"]
						[end-field-cil my-info-date "" [my-date: request-date end-field-cil/text: to-string my-date show end-field-cil]]
						[title-label-cil my-label "title"]
						[title-field-cil my-field field1]
					]
				]
				[
					below
					[
						[description-cil my-label "summary"]
						[description-field-cil my-area field2]
						[
							validate-cil my-button "validate" [

								either (test: validate-iteration begining-field-cil/text end-field-cil/text description-field-cil/text title-field-cil/text)
								[

									state-project-field/text: get-state-project
									end/pane: layout/offset/origin forum-iteration 1 0x0 5x5 show end
								]
								[
									alert ("problem with this iteration")

									foreach el wrong-fields [alert el]
									foreach el I-O-problem [alert el]
								]

							]
						]
					]
				]
			]
		]
		return create-iteration-lay
	]


	;ecran de pr�sentation d'une it�ration

	iteration-presentation: func [
		"g�n�re le layout qui pr�sente une it�ration"
		id-iteration [string!] "identifiant de l'it�ration a pr�senter"
	] [
		use [field1 field2 field3 field4 field5] [
			either (not id-iteration = "none") [
				field1: get-iteration-name id-iteration
				field2: to-string get-iteration-begining id-iteration
				field3: get-state-iteration id-iteration
				field4: to-string get-iteration-end id-iteration
				field5: get-iteration-description id-iteration
			]
			[
				field1: ""
				field2: ""
				field3: ""
				field4: ""
				field5: ""
			]

			iteration-presentation-layout: simple-layout-generator true ivory 500x200 [
				[
					across
					[
						[title-label-ipl my-label "iteration presentation"]
						"return"
						[iteration-label-ipl my-label "iteration :"]
						"tab"
						[name-iteration-field-ipl my-info field1]
						"return"
						[begin-iteration-label-ipl my-label "begin :"]
						[begin-info-ipl my-info-date field2]
						[end-iteration-label-ipl my-label "end :"]
						[end-info-ipl my-info-date field4]
						[iteration-label-ipl my-label "state :"]
						[state-iteration-field-ipl my-info-date field3]
						"return"
						[desc-iteration-label-ipl my-label "summary :"]
						"tab"
						[description-iteration-area-ipl my-info-area field5]
						"return"
						[
							create-ipl my-button "create" ["gerer l'affichage du panneau de creation de l'it�ration"
								mid/pane: layout/offset/origin create-iteration-layout 0x0 5x5
								show mid
								end/pane: layout/offset/origin forum-iteration 1 0x0 5x5
								show end
							]
						]
						[
							add-st-ipl my-button "add story" [
								"addition d'une histoire"
								end/pane: layout/offset/origin forum-story-add 1 (id-iteration) 0x0 5x5
								show end
							]
						]
					]
				]
			]
		]
	]
	; ecran de modification d'une it�ration
	modify-iteration-layout: func [
		"cree le bloc d'instructions vid qui va g�n�rer le layout de modification de l'it�ration"
		id-iteration [string!] "identifiant de l'it�ration a pr�senter"
	] [
		use [field1 field2 field3 field4 field5] [
			field1: get-iteration-name id-iteration
			field2: to-string get-iteration-begining id-iteration
			field3: get-state-iteration id-iteration
			field4: to-string get-iteration-end id-iteration
			field5: get-iteration-description id-iteration
			iteration-modification-layout: simple-layout-generator true ivory 500x200 [
				[
					across
					[
						[title-label-mil my-label "Iteration modification"]
						"return"
						[iteration-label-mil my-label "iteration :"]
						"tab"
						[name-iteration-field-mil my-field field1]
						"return"
						[begin-iteration-label-mil my-label "begin :"]
						[begin-info-mil my-info-date field2 [d: request-date begin-info-mil/text: d show begin-info-mil]]
						[end-iteration-label-mil my-label "end :"]
						[end-info-mil my-info-date field4 [d: request-date end-info-mil/text: d show end-info-mil]]
						"return"
						[desc-iteration-label-mil my-label "summary :"]
						"tab"
						[description-iteration-area-mil my-area field5]
						"return"
						[
							validate-mil my-button "validate" [
								test: validate-modified-iteration
								to-string begin-info-mil/text
								to-string end-info-mil/text
								description-iteration-area-mil/text
								name-iteration-field-mil/text id-iteration
								either (test)
								[
									name-iteration-field-mil/text: get-iteration-name id-iteration
									begin-info-mil/text: to-string get-iteration-begining id-iteration
									end-info-mil/text: to-string get-iteration-end id-iteration
									description-iteration-area-mil/text: get-iteration-description id-iteration
									end/pane: layout/offset/origin forum-iteration 1 0x0 5x5
									show end
								]
								[

									name-iteration-field-mil/text: get-iteration-name id-iteration
									begin-info-mil/text: to-string get-iteration-begining id-iteration
									end-info-mil/text: to-string get-iteration-end id-iteration
									description-iteration-area-mil/text: get-iteration-description id-iteration
									end/pane: layout/offset/origin forum-iteration 1 0x0 5x5
									show end
									foreach el wrong-fields [alert el]
									foreach el I-O-problem [alert el]
								]
							]

						]
					]
				]
			]
		]
	]
	;�crans d'une story

	;�cran de pr�sentation d'une story

	story-presentation: func [
		"g�n�re le bloc d'instruction vid de l'�cran"
		id-story ["string"]
	] [

		use [field1 field2 field3 field4 field5 field6 field7 field8] [
			either (not id-story = "none") [
				field1: to-string get-story-title id-story
				field2: to-string get-story-date id-story
				field3: to-string get-state-story id-story
				field4: to-string get-story-estimate id-story
				field5: to-string get-story-description id-story
				field6: to-string get-story-tech-risk id-story
				field7: to-string get-story-tech-priority id-story
				field8: to-string get-story-user-priority id-story
			]
			[
				field1: ""
				field2: ""
				field3: ""
				field4: ""
				field5: ""
				field6: ""
				field7: ""
				field8: ""
			]

			story-presentation-lay: simple-layout-generator true ivory 500x200 [
				[
					below
					[
						[title-psl my-label "Story presentation"]
					]
				]
				[
					across
					[
						[estimate-psl my-label "Estimate"]
						[estimate-info-psl my-info-number field4]
						[risk-csl my-label "Risk"]
						[risk-field-csl my-info-number field6]
						[user-prior-csl my-label "User priority"]
						[user-prior-field-csl my-info-number field8]
						[tech-prior-csl my-label "tech priority"]
						[tech-prior-field-csl my-info-number field7]
						"return"
						[title-label-csl my-label "title"]
						[title-field-csl my-info field1]
						[date-psl my-label "date"]
						[date-info-psl my-info-date field2]
						"return"
						[description-csl my-label "summary"]
						[description-field-csl my-info-area field5]
					]
				]
				[
					below
					[
						"across"
						[
							create-psl my-button "create" [
								mid/pane: layout/offset/origin create-story-layout 0x0 5x5
								show mid
								;end/pane: layout/offset/origin forum-story 1 0x0 5x5 
								;show end
							]
						]
						[btn-add-task-f-l: my-button "add task" [

								mid/pane: layout/offset/origin create-task-layout (id-story) 0x0 5x5 show mid


							]]
					]
				]
			]
		]
	]

	;ecran de creation d'une story

	create-story-layout: func ["cree le bloc d'instructions vid de l'�cran de creation d'une story"] [

		field1: copy ""
		field2: copy ""
		field3: copy ""
		field4: copy ""
		field5: copy ""
		field6: copy ""

		create-story-lay: simple-layout-generator true ivory 500x200 [
			[
				below
				[
					[first-time my-label "Story creation"]
				]
			]
			[
				across
				[
					[estimate-csl my-label "Estimate"]
					[estimate-field-csl my-field-number field1]
					[risk-csl my-label "Risk"]
					[risk-field-csl my-field-number field2]
					[user-prior-csl my-label "User priority"]
					[user-prior-field-csl my-field-number field3]
					[tech-prior-csl my-label "tech priority"]
					[tech-prior-field-csl my-field-number field4]
					"return" "tab"
					[title-label-csl my-label "title"]
					[title-field-csl my-field field5]
					"return"
					[description-csl my-label "summary"]
					[description-field-csl my-area field6]
				]
			]
			[
				below
				[
					[
						validate-csl my-button "validate" [
							either (validate-story to-string now/date description-field-csl/text title-field-csl/text estimate-field-csl/text risk-field-csl/text user-prior-field-csl/text tech-prior-field-csl/text)
							[
								estimate-field-csl/text: copy "" show estimate-field-csl
								risk-field-csl/text: copy "" show risk-field-csl
								user-prior-field-csl/text: copy "" show user-prior-field-csl
								tech-prior-field-csl/text: copy "" show tech-prior-field-csl
								title-field-csl/text: copy "" show title-label-csl
								description-field-csl/text: copy "" show description-field-csl
								end/pane: layout/offset/origin forum-story 1 0x0 5x5 show end
							]
							[
								alert ("problem with this story")
								foreach el wrong-fields [alert el]
								foreach el I-O-problem [alert el]
							]

						]
					]
				]
			]
		]

		return create-story-lay
	]

	;ecran de modification d'une story

	modify-story-layout: func [
		"fonction qui g�n�re le bloc d'instruction vid de l'�cran de modification de la story"
		id-story [string!] "identifiant de la story"
	] [
		use [field1 field2 field3 field4 field5 field6 field7 field8] [
			either (not id-story = "none") [
				field1: to-string get-story-title id-story
				field2: to-string get-story-date id-story
				field4: to-string get-story-estimate id-story
				field5: to-string get-story-description id-story
				field6: to-string get-story-tech-risk id-story
				field7: to-string get-story-tech-priority id-story
				field8: to-string get-story-user-priority id-story
			]
			[
				field1: ""
				field2: ""
				field3: ""
				field4: ""
				field5: ""
				field6: ""
				field7: ""
				field8: ""
			]
			story-modification-lay: simple-layout-generator true ivory 500x200 [
				[
					below
					[
						[title-psl my-label "Story modification"]
					]
				]
				[
					across
					[
						[estimate-msl my-label "Estimate"]
						[estimate-field-msl my-field-number field4]
						[risk-msl my-label "Risk"]
						[risk-field-msl my-field-number field6]
						[user-prior-msl my-label "User priority"]
						[user-prior-field-msl my-field-number field8]
						[tech-prior-msl my-label "tech priority"]
						[tech-prior-field-msl my-field-number field7]
						"return"
						[title-label-msl my-label "title"]
						[title-field-msl my-field field1]
						[date-psl my-label "date"]
						[date-info-msl my-info-date field2 [d: request-date date-info-msl/text: d show date-info-msl]]
						"return"
						[description-msl my-label "summary"]
						[description-field-msl my-area field5]
					]
				]
				[
					below
					[
						[
							create-psl my-button "validate" [
								test: validate-modified-story
								to-string date-info-msl/text
								description-field-msl/text
								title-field-msl/text
								estimate-field-msl/text
								risk-field-msl/text
								user-prior-field-msl/text
								tech-prior-field-msl/text
								id-story
								either (test)
								[
									title-field-msl/text: to-string get-story-title id-story
									date-info-msl/text: to-string get-story-date id-story
									estimate-field-msl/text: to-string get-story-estimate id-story
									field5: to-string get-story-description id-story
									risk-field-msl/text: to-string get-story-tech-risk id-story
									tech-prior-field-msl/text: to-string get-story-tech-priority id-story
									user-prior-field-msl/text: to-string get-story-user-priority id-story
									end/pane: layout/offset/origin forum-story 1 0x0 5x5
									show end
								]
								[
									title-field-msl/text: to-string get-story-title id-story
									date-info-msl/text: to-string get-story-date id-story
									estimate-field-msl/text: to-string get-story-estimate id-story
									field5: to-string get-story-description id-story
									risk-field-msl/text: to-string get-story-tech-risk id-story
									tech-prior-field-msl/text: to-string get-story-tech-priority id-story
									user-prior-field-msl/text: to-string get-story-user-priority id-story
									foreach el I-O-problem [alert el]
									foreach el wrong-fields [alert el]
								]
							]
						]
					]
				]
			]
		]
		return story-modification-lay
	]
	;�crans d'une task
	;cr�ation d'une task

	create-task-layout: func [
		"g�n�re le bloc d'instruction vid de l'�cran de cr�ation des tasks"
		id-story [string!] "identifiant de la story a laquelle la task sera rattach�e"
	] [
		use [field1 field2 field3 field4 field5 field6] [
			field1: copy ""
			field2: copy ""
			field3: copy ""
			field4: copy ""
			field5: copy ""
			field6: copy ""
			create-task-lay: simple-layout-generator true ivory 500x200 [
				[
					below
					[
						[first-time my-label "Task creation"]
					]
				]
				[
					across
					[
						"tab"
						[my-title-task-mtl my-label-task "title"]
						[my-title-task-field-mtl my-field-task field1]
						"return"
						[my-in-task-mtl my-label-task "In"]
						[my-in-task-field-mtl my-area-task field3]
						[my-out-task-mtl my-label-task "out"]
						[my-out-task-field-mtl my-area-task field4]
						"return"
						[my-responsabilities-task-mtl my-label-task "Resp."]
						[my-responsabilities-task-mtl my-area-task field5]
						[my-collaborations-task-mtl my-label-task "Coll."]
						[my-collaborations-task-field-mtl my-area-task field6]
					]
				]
				[
					below
					[
						[
							validate-csl my-button "validate" [
								either (validate-task id-story now/date my-title-task-field-mtl/text my-in-task-field-mtl/text my-out-task-field-mtl/text my-responsabilities-task-mtl/text my-collaborations-task-field-mtl/text)
								[
									end/pane: layout/offset/origin forum-task (id-story) 1 0x0 5x5 show end
								]
								[
									alert ("problem with this task")
									foreach el wrong-fields [alert el]
									foreach el I-O-problem [alert el]
								]

							]
						]
					]
				]
			]
		]
		return create-task-lay
	]

	;�cran de modification d'une task

	modify-task-layout: func [
		"g�n�re le bloc d'instruction vid de l'�cran de modification de la task"
		id-task [string!] "identifiant de la task"

	] [
		use [field1 field2 field3 field4 field5 field6 field7] [
			either (not id-task = "none") [
				field1: get-title-task id-task
				object-story: load-story get-story-task id-task
				field2: object-story/title-story
				field3: get-in-task id-task
				field4: get-out-task id-task
				field5: get-responsabilities-task id-task
				field6: get-collaborations-task id-task
				field7: get-date-task id-task
			]
			[
				field1: ""
				field2: ""
				field3: ""
				field4: ""
				field5: ""
				field6: ""
				field7: ""
			]
			task-modification-lay: simple-layout-generator true ivory 500x200 [
				[
					below
					[
						[first-time my-label "Task modification"]
					]
				]
				[
					across
					[
						[my-title-task-mtl my-label-task "title"]
						[my-title-task-field-mtl my-field-task field1]
						[my-story-task-mtl my-label-task "Story"]
						[my-story-task-field-mtl my-field-task field2]
						"return"
						[my-in-task-mtl my-label-task "In"]
						[my-in-task-field-mtl my-area-task field3]
						[my-out-task-mtl my-label-task "out"]
						[my-out-task-field-mtl my-area-task field4]
						"return"
						[my-responsabilities-task-mtl my-label-task "Resp."]
						[my-responsabilities-task-mtl my-area-task field5]
						[my-collaborations-task-mtl my-label-task "Coll."]
						[my-collaborations-task-field-mtl my-area-task field6]
						"return"
					]
				]
				[
					across
					[
						[
							validate-psl my-button "validate" [
								either (validate-task id-story now/date my-title-task-field-mtl/text my-story-task-field-mtl/text my-in-task-field-mtl/text my-out-task-field-mtl/text my-responsabilities-task-mtl/text my-collaborations-task-field-mtl/text)
								[
									end/pane: layout/offset/origin forum-task (id-story) 1 0x0 5x5 show end
								]
								[
									alert ("problem with this task")
									foreach el wrong-fields [alert el]
									foreach el I-O-problem [alert el]
								]
							]
						]
						[my-title-task-mtl my-label-task "date"]
						[my-title-task-field-mtl my-field-task field7]
					]
				]
			]
		]
		return task-modification-lay
	]

	;�cran de pr�sentation d'une task

	task-presentation: func [
		"cree le bloc d'instructions vid de l'�cran de pr�sentation des tasks"
		id-task [string!]
	] [use [field1 field2 field3 field4 field5 field6] [
			field1: get-title-task id-task
			get-story-task id-task
			object-story: load-story get-story-task id-task
			field2: object-story/title-story
			field3: get-in-task id-task
			field4: get-out-task id-task
			field5: get-responsabilities-task id-task
			field6: get-collaborations-task id-task
			field7: get-date-task id-task
			field8: get-story-task id-task
			presentation-task-lay: simple-layout-generator true ivory 500x200 [
				[
					below
					[
						[first-time my-label "Task presentation"]
					]
				]
				[
					across
					[
						[my-title-task-ptl my-label-task "title"]
						[my-title-task-field-ptl my-field-task field1]
						[my-story-task-ptl my-label-task "Story"]
						[my-story-task-field-ptl my-field-task field2]
						"return"
						[my-in-task-ptl my-label-task "In"]
						[my-in-task-field-ptl my-area-task field3]
						[my-out-task-ptl my-label-task "out"]
						[my-out-task-field-ptl my-area-task field4]
						"return"
						[my-responsabilities-task-ptl my-label-task "Resp."]
						[my-responsabilities-task-ptl my-area-task field5]
						[my-collaborations-task-ptl my-label-task "Coll."]
						[my-collaborations-task-field-ptl my-area-task field6]
						"return"
						[my-title-task-ptl my-label-task "date"]
						[my-title-task-field-ptl my-field-task field7]
						[
							validate-rep: my-button "To story"
							[
								mid/pane: layout/offset/origin story-presentation field8 0x0 5x5 show mid
								end/pane: layout/offset/origin forum-task field8 1 0x0 5x5 show end
							]

						]
						[
							btn-add-f-l: my-button "add test" [
								mid/pane: layout/offset/origin create-test-layout id-task 0x0 5x5 show mid
							]
						]
					]
				]

			]
		]
		return presentation-task-lay
	]


	working-task-presentation: func [
		"pr�sente la task en cours"
		id-task "identifiant de la task"
	]
	[
		use [field1 field2 field3 field4 field5 field6] [
			field1: get-title-task id-task
			get-story-task id-task
			object-story: load-story get-story-task id-task
			field2: object-story/title-story
			field3: get-in-task id-task
			field4: get-out-task id-task
			field5: get-responsabilities-task id-task
			field6: get-collaborations-task id-task
			field7: get-date-task id-task
			field8: get-story-task id-task
			presentation-task-lay: simple-layout-generator true ivory 500x200 [
				[
					below
					[
						[first-time my-label " Your mission :"]
					]
				]
				[
					across
					[
						[my-title-task-ptl my-label-task "title"]
						[my-title-task-field-ptl my-field-task field1]
						[my-story-task-ptl my-label-task "Story"]
						[my-story-task-field-ptl my-field-task field2]
						"return"
						[my-in-task-ptl my-label-task "In"]
						[my-in-task-field-ptl my-area-task field3]
						[my-out-task-ptl my-label-task "out"]
						[my-out-task-field-ptl my-area-task field4]
						"return"
						[my-responsabilities-task-ptl my-label-task "Resp."]
						[my-responsabilities-task-ptl my-area-task field5]
						[my-collaborations-task-ptl my-label-task "Coll."]
						[my-collaborations-task-field-ptl my-area-task field6]
						"return"
						[my-title-task-ptl my-label-task "date"]
						[my-title-task-field-ptl my-field-task field7]
						[
							validate-rep: my-button "leave task"
							[
								either (request/confirm "do you produce production code ?")
								[
									leave-task-prod-code (id-task)
									mid/pane: layout/offset/origin story-presentation field8 0x0 5x5 show mid
									end/pane: layout/offset/origin forum-task field8 1 0x0 5x5 show end
								]
								[
									leave-task-spike (id-task)
									mid/pane: layout/offset/origin story-presentation field8 0x0 5x5 show mid
									end/pane: layout/offset/origin forum-task field8 1 0x0 5x5 show end
								]
							]

						]
						[
							btn-add-f-l: my-button "add test" [
								mid/pane: layout/offset/origin create-test-layout id-task 0x0 5x5 show mid
							]
						]
					]
				]

			]
		]
		return presentation-task-lay


	]

	take-task-layout: func [
		"presenter la saisie d'une task"
		id-task [string!] "identifiant de la task"
	]
	[
		take-task-lay: simple-layout-generator true ivory 500x200 [
			[
				across
				[
					[ord-rep my-text "You are about to take this task. If you work in pair, give the name of your companion, let it blank if you are alone"]
					"return"
					[name-companion my-text "name :"]
					[name-companion-field my-field ""]
					"return"
					[
						validate-rep: button "validate"
						[either (check-companion name-companion-field/text)
							[
								either (take-task (id-task))
								[
									mid/pane: layout/offset/origin working-task-presentation (id-task) 0x0 5x5 show mid
									end/pane: layout/offset/origin forum-test-working (id-task) 1 0x0 5x5 show end
								]
								[
									alert "You cannot take this task"
									if (not empty? working-task)
									[
										alert "dont forget your mission"
										mid/pane: layout/offset/origin working-task-presentation (id-task) 0x0 5x5 show mid
										end/pane: layout/offset/origin forum-test-working (id-task) 1 0x0 5x5 show end
									]
								]
							] [
								mid/pane: layout/offset/origin add-companion-layout (id-task) 0x0 5x5 show mid
								end/pane: layout/offset/origin [box 500x225 ivory] 0x0 5x5 show end
							]
						]
					]
				]
				return take-task-lay
			]
		]
	]

	;�cran de cr�ation d'un test
	create-test-layout: func [
		"cree le bloc d'instructions vid de l'�cran de creation d'un test"
		id-task [string!]
	] [
		use [field1] [

			create-test-lay: simple-layout-generator true ivory 500x200 [
				[
					below
					[
						[first-time my-label "Test creation"]
					]
				]
				[
					across
					[
						[In-ctel my-label "In"]
						[In-ctel my-field-small ""]
						[Out-label-ctel my-label "Out"]
						[Out-field-ctel my-field-small ""]
						"return"
						[description-ctel my-label "summary"]
						[description-field-ctel my-area ""]
						"return"
						[Pre-cond-ctel my-label "Pre-cond"]
						[Pre-cond-field-ctel my-field-small ""]
						[Post-cond-ctel my-label "Post-cond"]
						[Post-cond-field-ctel my-field-small ""]

					]
				]
				[
					below
					[
						[
							validate-ctel my-button "validate" [
								either (
									validate-test
									id-task
									now/date
									description-field-ctel/text
									Pre-cond-field-ctel/text
									Post-cond-field-ctel/text
									In-ctel/text
									Out-field-ctel/text
								)
								[

									description-field-ctel/text: "" show description-field-ctel
									In-ctel/text: "" show In-ctel
									Out-field-ctel/text: "" show Out-field-ctel
									Pre-cond-field-ctel/text: "" show Pre-cond-field-ctel
									Post-cond-field-ctel/text: "" show Post-cond-field-ctel

								]
								[
									alert ("problem with this test")
									foreach el wrong-fields [alert el]
									foreach el I-O-problem [alert el]
								]

							]
						]
					]
				]
			]
		]
		return create-test-lay
	]
	;�cran de pr�sentation d'un test
	test-presentation: func [
		"cree le bloc d'instructions vid de l'�cran de pr�sentation des tests"
		id-test [string!]
	] [
		field1: get-in-test id-test
		field2: get-out-test id-test
		field3: get-summary-test id-test
		field4: to-string get-date-test id-test
		field5: get-state-test id-test
		field6: get-pre-cond-test id-test
		field7: get-post-cond-test id-test
		id-task: get-task-test id-test

		presentation-test-lay: simple-layout-generator true ivory 500x200 [
			[
				below
				[
					[first-time my-label "Test presentation"]
				]
			]
			[
				across
				[
					[In-ctel my-label "In"]
					[In-ctel my-field-small field1]
					[Out-label-ctel my-label "Out"]
					[Out-field-ctel my-field-small field2]
					"return"
					[description-ctel my-label "summary"]
					[description-field-ctel my-area field3]
					"return"
					[Pre-cond-ctel my-label "Pre-cond"]
					[Pre-cond-field-ctel my-field-small field6]
					[Post-cond-ctel my-label "Post-cond"]
					[Post-cond-field-ctel my-field-small field7]
					"return"
					[date-ctel my-label "date"]
					[date-field-ctel my-field-small field4]
					[state-ctel my-label "state"]
					[state-field-ctel my-field-small field5]
					[validate-login my-button "To task" [
							mid/pane: layout/offset/origin task-presentation (id-task) 0x0 5x5 show mid
							end/pane: layout/offset/origin forum-test (id-task) 1 0x0 5x5 show end

						]
					]


				]
			]
		]
		return presentation-test-lay
	]


	test-taken-presentation: func [
		"cree le bloc d'instructions vid de l'�cran de pr�sentation des tests"
		id-test [string!]
	] [
		field1: get-in-test id-test
		field2: get-out-test id-test
		field3: get-summary-test id-test
		field4: to-string get-date-test id-test
		field5: get-state-test id-test
		field6: get-pre-cond-test id-test
		field7: get-post-cond-test id-test
		id-task: get-task-test id-test

		presentation-test-lay: simple-layout-generator true ivory 500x200 [
			[
				below
				[
					[first-time my-label "Test presentation"]
				]
			]
			[
				across
				[
					[In-ctel my-label "In"]
					[In-ctel my-field-small field1]
					[Out-label-ctel my-label "Out"]
					[Out-field-ctel my-field-small field2]
					"return"
					[description-ctel my-label "summary"]
					[description-field-ctel my-area field3]
					"return"
					[Pre-cond-ctel my-label "Pre-cond"]
					[Pre-cond-field-ctel my-field-small field6]
					[Post-cond-ctel my-label "Post-cond"]
					[Post-cond-field-ctel my-field-small field7]
					"return"
					[date-ctel my-label "date"]
					[date-field-ctel my-field-small field4]
					[state-ctel my-label "state"]
					[state-field-ctel my-field-small field5]
					[validate-login my-button "To task" [
							mid/pane: layout/offset/origin working-task-presentation (id-task) 0x0 5x5 show mid
							end/pane: layout/offset/origin forum-test (id-task) 1 0x0 5x5 show end
						]
					]


				]
			]
		]
		return presentation-test-lay
	]

	repository-modification-layout: func [
		"permet de changer de repository"

	] [
		rep-mod-lay: simple-layout-generator true ivory 500x200 [
			[
				across
				[
					[ord-rep my-text "type the url of your repository or let it blank if you dont have one"]
					"return"
					[text-rep my-text "URL :"]
					[url-rep-file my-field ""]
					"return"
					[
						validate-rep: button "validate"
						[either (validate-repository url-rep-file/text)
							[
								alert "done"
							] [
								alert wrong-fields
							]
						]
					]
				]
				return rep-mod-lay
			]
		]
	]


	add-companion-layout: func [
		"ecran de creation du binome"
		id-task [string!] "identifiant de la task"
	] [
		use [field1 field2] [
			foreach el wrong-fields [alert el]
			field1: copy ""
			field2: copy ""
			end/pane: layout/offset/origin [box 500x200 ivory] 0x0 5x5 show end
			c-u-lay: simple-layout-generator true ivory 500x200 [
				[
					below
					[
						[first-time my-label "it seems that your friend is not registred, please register him : his name is needed"]
					]
				]
				[
					below
					[
						[name-label my-label "name"]
						[name-field my-field field1]
						[email-label my-label "email"]
						[email-field my-field field2]
						[validate-login my-button "validate" [either (validate-user name-field/text email-field/text)
								[
									field1: ""
									field2: ""
									show mid
									alert "done"
									mid/pane: layout/offset/origin take-task-layout id-task 0x0 5x5 show mid
									end/pane: layout/offset/origin forum-test id-task 1 0x0 5x5 show end
								]
								[
									foreach el wrong-fields [alert el]
								]
							]
						]
					]
				]
			]
		]
	]


	princ-lay: [
		at 2x2
		en-tete-logo: panel 500x60 0.0.125 [
			logo: text "XPDev" yellow font-size 20
			across
			en-tete: text "you are logged as" yellow font-size 12
			name-logo: text get-name-user yellow [alert rejoin ["email: " get-email-user get-name-user]]
			on-proj: text "on the project" yellow font-size 12
			proj-info-logo: text 125x24 get-project-name yellow
			[
				mid/pane: layout/offset/origin project-presentation-layout 0x0 5x5 show mid
				end/pane: layout/offset/origin forum-iteration 1 0x0 5x5 show end
			]
		]
		menu: panel 500x30 0.255.187 [
			at 5x5
			first-text: text "Iteration" underline [
				mid/pane: layout/offset/origin iteration-presentation get-first-iteration 0x0 5x5 show mid
				end/pane: layout/offset/origin forum-iteration 1 0x0 5x5 show end
			]
			at 55x5
			second-text: text "Story" underline [
				mid/pane: layout/offset/origin story-presentation get-first-story 0x0 5x5 show mid
				end/pane: layout/offset/origin forum-story 1 0x0 5x5 show end
			]
			at 95x5
			text "|"
			at 125x5
			text "Repository" underline [
				mid/pane: layout/offset/origin repository-modification-layout 0x0 5x5 show mid
				end/pane: layout/offset/origin [box 500x250 ivory] 0x0 5x5 show end
			]
		]

		mid: box 500x200
		end: box blue 500x225
		do [
			mid/pane: layout/offset/origin project-presentation-layout 0x0 5x5 show mid
			end/pane: layout/offset/origin forum-iteration 1 0x0 5x5 show end
		]
	]
]



;ecrans de situ�s hors de la fenetre principale


;ecran de creation du projet
launch-project-layout: func [
	"genere l'�cran permettant de creer un projet"
] [
	use [field1 field2 field3 field4] [
		foreach el wrong-fields [alert el]
		field1: copy ""
		field2: copy ""
		launch-proj-lay: simple-layout-generator true green 500x200 [
			[
				below
				[
					[first-time my-label "it seems that you are about to launch a project, fill the fields and ... GOOD LUCK"]
				]
			]
			[
				across
				[
					[project-label my-label "project :"]
					"tab"
					[name-project-field my-field field1]
					"return"
					[desc-label my-label "summary :"]
					"tab"
					[description-area my-area field2]
					"return"
					[
						validate my-button "validate" [either (validate-project name-project-field/text description-area/text)
							[
								view layout main-layout
							]
							[
								foreach el wrong-fields [alert el]
								foreach el I-O-problem [alert el]
							]
						]
					]
				]
			]
		]
		return launch-proj-lay
	]
]

;ecran de creation d'un user
create-user-layout: func [
	"ecran de creation du user"
] [
	use [field1 field2] [
		foreach el wrong-fields [alert el]
		field1: copy ""
		field2: copy ""
		c-u-lay: simple-layout-generator true green 500x200 [
			[
				below
				[
					[first-time my-label "it seems that you attempt to connect for the first time, please register your informations : your name is needed"]
				]
			]
			[
				across
				[
					[name-label my-label "name"]
					[name-field my-field field1]
				]
			]
			[
				return
				[]
			]
			[
				across
				[
					[email-label my-label "email"]
					[email-field my-field field2]
					[validate-login my-button "validate" [either (validate-user name-field/text email-field/text)
							[

								view layout login-layout []
							]
							[
								foreach el wrong-fields [alert el]
							]
						]]]
			]

		]
	]
]

;login sans password
login-layout: func [
	"login sans password"
] [
	field1: copy ""
	simple-layout-generator true ivory 300x200 [
		[
			below
			[
				[first-time my-label "Welcome on XPDev"]
			]
		]
		[
			across
			[
				[name-login my-label "name"]
				[name-field-login my-field field1]
			]
		]
		[
			below
			[
				[
					validate-login my-button "validate"
					[
						either (check-existence-user name-field-login/text)
						[
							set-name-user name-field-login/text
							either (check-name-project)
							[
								view layout
								main-layout
							]
							[
								view layout
								launch-project-layout []
							]
						]
						[
							view layout
							create-user-layout []
						]
					]
				]
			]
		]
	]
]
;�cran de saisie du repository

repository-layout: func [
	"objet face de l'�cran de saisie de l'url du repository"
] [layout [
		across
		text-rep: text underline font-size 16 "type the url of your repository or let it blank if you dont have one"
		return
		text-rep: text font-size 16 black "URL "
		url-rep: field 250x20 ""
		return
		validate-rep: button "validate"
		[either (validate-repository url-rep/text)
			[
				view layout login-layout
			] [
				alert wrong-fields
			]
		]
	]]


;point d'entr�e du mvc

either (repository-url/1 = "none")
[
	rep-lay: repository-layout
	rep-lay/offset: 350x500
	view layout rep-lay
]
[
	view layout login-layout
]
