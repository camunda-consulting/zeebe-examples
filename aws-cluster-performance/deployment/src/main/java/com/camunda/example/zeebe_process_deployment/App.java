package com.camunda.example.zeebe_process_deployment;

import java.util.Properties;
import java.util.concurrent.ExecutionException;

import io.zeebe.client.ClientProperties;
import io.zeebe.client.ZeebeClient;
import io.zeebe.client.api.commands.Topology;
import io.zeebe.client.api.events.DeploymentEvent;

public class App {
	public static void main(String[] args) throws InterruptedException, ExecutionException {
		Properties clientProperties = new Properties();
		clientProperties.put(ClientProperties.BROKER_CONTACTPOINT,
				"YOUR_PUBLIC_AWS_DNS_NAME:51015");

		final ZeebeClient client = ZeebeClient.newClientBuilder().withProperties(clientProperties).build();
		Topology response = client.newTopologyRequest()
				.send()
				.get();
		System.out.println(response.toString());
		client.newCreateTopicCommand()
				.name("our-topic")
				.partitions(120)
				.replicationFactor(1)
				.send()
				.get();

		DeploymentEvent event = client.topicClient("our-topic")
				.workflowClient()
				.newDeployCommand()
				.addResourceFromClasspath("example-process.bpmn")
				.send()
				.get();
		System.out.println(event.getState());

	}
}
