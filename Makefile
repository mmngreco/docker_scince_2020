run:
	docker build -t scince .
	docker run -v "${PWD}/scince_2020":/scince_2020 scince
