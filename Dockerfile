# syntax=docker/dockerfile:1

FROM python AS builder
RUN pwd

FROM builder AS build1
RUN ls

