# syntax=docker/dockerfile:1

FROM ubuntu:22.04 AS builder
RUN pwd

FROM builder AS build1
RUN ls

FROM builder AS build2
RUN ls -l
