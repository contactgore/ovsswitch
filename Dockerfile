FROM centos:centos7


# Install dependencies
RUN yum -y install  python-setuptools logrotate python-six selinux-policy-targeted
RUN easy_install supervisor
COPY  *.rpm /opt/
RUN rpm -ivh /opt/*.rpm

# ////////////// Open vSwitch Section ////////////// #

# Create database and pid file directory
RUN /usr/bin/ovsdb-tool create /etc/openvswitch/conf.db
RUN mkdir -pv /var/run/openvswitch/  /usr/share/openvswitch/ /usr/local/share/openvswitch/ /var/log/supervisor/
RUN mkdir -pv /usr/share/openvswitch/
RUN mkdir -pv /usr/local/share/openvswitch/
RUN mkdir -pv /var/log/supervisor/
RUN mkdir -pv /etc/supervisor/conf.d
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add supervisord configuration file
ADD supervisord.conf /etc/supervisord.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD openvswitch.init /usr/share/openvswitch/openvswitch.init
ADD config-ovs.sh /usr/local/share/openvswitch/config-ovs.sh
RUN cp  /usr/sbin/ovs* /usr/local/sbin/

WORKDIR /etc/supervisor/conf.d

# Define default command.
ENTRYPOINT ["/usr/bin/supervisord"]
