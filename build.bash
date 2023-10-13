#! /bin/bash

name="jnginx"
ver="3"
repo="k83:5000"

docker build -t ${repo}/${name}:${ver} .

