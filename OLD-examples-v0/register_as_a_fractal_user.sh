#!/bin/bash

PORT=8001
curl -d '{"email":"test@me.com", "password":"test", "slurm_user":"test01"}' -H "Content-Type: application/json" -X POST localhost:${PORT}/auth/register
