FROM rainbond/cedar14:20180416

LABEL MAINTAINER ="zhengys <zhengys@goodrain.com>"

# 时区设置
RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata && \
    sed -i "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config && \
    mkdir /root/.ssh

ADD ./id_rsa /root/.ssh/id_rsa
ADD ./id_rsa.pub /root/.ssh/
ADD ./builder/ /tmp/builder
ADD ./pre-compile/ /tmp/pre-compile
ADD ./buildpacks /tmp/buildpacks

RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_rsa && \
    mkdir /app && \
    addgroup --quiet --gid 200 rain && \
    useradd rain --uid=200 --gid=200 --home-dir /app --no-create-home && \
    /tmp/builder/install-buildpacks && \
    chown rain.rain -R /tmp/pre-compile /tmp/builder /tmp/buildpacks && \
    chown -R rain:rain /app && \
    wget -q https://buildpack.oss-cn-shanghai.aliyuncs.com/common/utils/jqe -O /usr/bin/jqe && chmod +x /usr/bin/jqe

USER rain

ENV HOME /app
ENV RELEASE_DESC=__RELEASE_DESC__

ENTRYPOINT ["/tmp/builder/build.sh"]
